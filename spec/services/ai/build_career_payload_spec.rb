# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::AI::BuildCareerPayload do
  describe '#call' do
    let(:user) { create(:user) }
    let(:resume) { create(:resume, :with_file, user: user) }

    before do
      allow_any_instance_of(Services::Resumes::ExtractText).to receive(:call).and_return('Resume text content')
    end

    context 'when resume has no positions with interview stages' do
      it 'raises ArgumentError' do
        create(:position, user: user, resume: resume)

        expect { described_class.new(user_id: user.id, resume_id: resume.id).call }
          .to raise_error(ArgumentError, /No positions with interview stages/)
      end
    end

    context 'when resume has positions with interview stages' do
      it 'returns payload with resume info and positions' do
        position = create(:position, user: user, resume: resume)
        create(:interview_stage, position: position, stage_type: 'hr', status: 'done')

        result = described_class.new(user_id: user.id, resume_id: resume.id).call

        expect(result[:resume_title]).to eq(resume.name)
        expect(result[:resume_text]).to eq('Resume text content')
        expect(result[:positions].size).to eq(1)
        expect(result[:positions].first[:title]).to eq(position.title)
        expect(result[:positions].first[:company_name]).to eq(position.company.name)
      end

      it 'excludes positions without interview stages' do
        position_with_stage = create(:position, user: user, resume: resume)
        create(:interview_stage, position: position_with_stage)
        create(:position, user: user, resume: resume)

        result = described_class.new(user_id: user.id, resume_id: resume.id).call

        expect(result[:positions].size).to eq(1)
        expect(result[:positions].first[:title]).to eq(position_with_stage.title)
      end

      it 'includes interview stage details' do
        position = create(:position, user: user, resume: resume)
        stage = create(:interview_stage,
                       position: position,
                       stage_type: 'technical',
                       status: 'done',
                       scheduled_at: Time.zone.parse('2026-04-01 10:00'),
                       notes: 'Some notes')

        result = described_class.new(user_id: user.id, resume_id: resume.id).call
        stage_data = result[:positions].first[:interview_stages].first

        expect(stage_data[:stage_type]).to eq('technical')
        expect(stage_data[:status]).to eq('done')
        expect(stage_data[:scheduled_at]).to eq('2026-04-01T10:00:00Z')
        expect(stage_data[:notes]).to eq('Some notes')
      end

      it 'includes feedback content when present' do
        position = create(:position, user: user, resume: resume)
        stage = create(:interview_stage, position: position)
        create(:feedback, interview_stage: stage, feedback_type: 'self_review', content: 'I did well')
        create(:feedback, interview_stage: stage, feedback_type: 'company', content: 'Good candidate')

        result = described_class.new(user_id: user.id, resume_id: resume.id).call
        stage_data = result[:positions].first[:interview_stages].first

        expect(stage_data[:self_feedback]).to eq('I did well')
        expect(stage_data[:company_feedback]).to eq('Good candidate')
      end

      it 'omits optional fields when nil or absent' do
        position = create(:position, user: user, resume: resume)
        create(:interview_stage, position: position, notes: nil)

        result = described_class.new(user_id: user.id, resume_id: resume.id).call
        stage_data = result[:positions].first[:interview_stages].first

        expect(stage_data).not_to have_key(:notes)
        expect(stage_data).not_to have_key(:self_feedback)
        expect(stage_data).not_to have_key(:company_feedback)
      end
    end
  end
end
