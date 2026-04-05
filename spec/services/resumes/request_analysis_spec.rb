# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::Resumes::RequestAnalysis do
  describe '#call' do
    let(:user) { create(:user) }

    context 'when resume is not analyzable' do
      it 'returns error when file is not attached' do
        resume = create(:resume, user: user)
        position = create(:position, user: user, resume: resume)
        create(:interview_stage, position: position)

        result = described_class.new(resume).call

        expect(result[:success]).to be(false)
        expect(result[:error]).to include('no attached file')
      end

      it 'returns error when no positions with interview stages' do
        resume = create(:resume, :with_file, user: user)

        result = described_class.new(resume).call

        expect(result[:success]).to be(false)
        expect(result[:error]).to include('no positions with interview stages')
      end
    end

    context 'when analysis is already in progress' do
      it 'returns error when status is pending' do
        resume = create(:resume, :with_file, user: user)
        position = create(:position, user: user, resume: resume)
        create(:interview_stage, position: position)
        create(:resume_analysis, resume: resume, status: :pending)

        result = described_class.new(resume).call

        expect(result[:success]).to be(false)
        expect(result[:error]).to include('already in progress')
      end

      it 'returns error when status is processing' do
        resume = create(:resume, :with_file, user: user)
        position = create(:position, user: user, resume: resume)
        create(:interview_stage, position: position)
        create(:resume_analysis, resume: resume, status: :processing)

        result = described_class.new(resume).call

        expect(result[:success]).to be(false)
        expect(result[:error]).to include('already in progress')
      end
    end

    context 'when resume is analyzable and no analysis in progress' do
      let(:resume) { create(:resume, :with_file, user: user) }

      before do
        position = create(:position, user: user, resume: resume)
        create(:interview_stage, position: position)
      end

      it 'creates a new analysis with pending status' do
        result = described_class.new(resume).call

        expect(result[:success]).to be(true)
        expect(result[:analysis].status).to eq('pending')
        expect(result[:analysis]).to be_persisted
      end

      it 'enqueues GenerateResumeAnalysisJob' do
        expect { described_class.new(resume).call }
          .to have_enqueued_job(GenerateResumeAnalysisJob)
          .with(user_id: user.id, resume_id: resume.id)
      end

      it 'resets existing completed analysis to pending' do
        existing = create(:resume_analysis, resume: resume, status: :completed,
                                            content: 'old', tokens_used: 100, model: 'old-model')

        result = described_class.new(resume).call

        expect(result[:success]).to be(true)
        existing.reload
        expect(existing.status).to eq('pending')
        expect(existing.content).to be_nil
        expect(existing.tokens_used).to be_nil
        expect(existing.model).to be_nil
      end

      it 'resets existing failed analysis to pending' do
        existing = create(:resume_analysis, resume: resume, status: :failed, error_message: 'old error')

        result = described_class.new(resume).call

        expect(result[:success]).to be(true)
        existing.reload
        expect(existing.status).to eq('pending')
        expect(existing.error_message).to be_nil
      end
    end
  end
end
