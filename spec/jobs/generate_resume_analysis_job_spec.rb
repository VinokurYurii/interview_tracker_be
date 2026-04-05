# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateResumeAnalysisJob, type: :job do
  let(:user) { create(:user) }
  let(:resume) { create(:resume, :with_file, user: user) }
  let(:gemini_response) do
    { content: 'AI career analysis', tokens_used: 150, model: 'gemini-2.5-flash' }
  end

  before do
    allow_any_instance_of(Services::AI::GenerateCareerInsights).to receive(:call).and_return(gemini_response)
  end

  describe '#perform' do
    it 'updates analysis to completed with AI response' do
      analysis = create(:resume_analysis, resume: resume, status: :pending)

      described_class.perform_now(user_id: user.id, resume_id: resume.id)

      analysis.reload
      expect(analysis.status).to eq('completed')
      expect(analysis.content).to eq('AI career analysis')
      expect(analysis.tokens_used).to eq(150)
      expect(analysis.model).to eq('gemini-2.5-flash')
    end

    context 'when API call fails' do
      before do
        allow_any_instance_of(Services::AI::GenerateCareerInsights)
          .to receive(:call)
          .and_raise(Services::AI::GeminiClient::ApiError, 'API failure')
      end

      it 'sets status to failed with error message' do
        create(:resume_analysis, resume: resume, status: :pending)

        expect { described_class.perform_now(user_id: user.id, resume_id: resume.id) }
          .to raise_error(Services::AI::GeminiClient::ApiError)

        analysis = resume.reload.resume_analysis
        expect(analysis.status).to eq('failed')
        expect(analysis.error_message).to eq('API failure')
      end
    end

    context 'when no analysis record exists' do
      it 'raises RecordNotFound' do
        expect { described_class.perform_now(user_id: user.id, resume_id: resume.id) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
