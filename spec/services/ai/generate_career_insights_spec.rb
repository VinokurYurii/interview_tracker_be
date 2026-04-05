# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::AI::GenerateCareerInsights do
  describe '#call' do
    let(:user) { create(:user) }
    let(:resume) { create(:resume, :with_file, user: user) }
    let(:payload) do
      {
        resume_title: resume.name,
        resume_text: 'Resume text',
        positions: [{ title: 'Dev', company_name: 'Acme', status: 'active', interview_stages: [] }]
      }
    end
    let(:gemini_response) do
      { content: 'AI analysis result', tokens_used: 100, model: 'gemini-2.5-flash' }
    end

    before do
      allow_any_instance_of(Services::AI::BuildCareerPayload).to receive(:call).and_return(payload)
      allow(Services::AI::GeminiClient).to receive(:call).and_return(gemini_response)
    end

    it 'returns the full GeminiClient response' do
      result = described_class.new(user_id: user.id, resume_id: resume.id).call

      expect(result).to eq(gemini_response)
    end

    it 'calls GeminiClient with prompt containing payload JSON' do
      described_class.new(user_id: user.id, resume_id: resume.id).call

      expect(Services::AI::GeminiClient).to have_received(:call).with(
        prompt: a_string_including(payload.to_json),
        system: described_class::SYSTEM_PROMPT
      )
    end

    it 'calls GeminiClient with system prompt about career consulting' do
      described_class.new(user_id: user.id, resume_id: resume.id).call

      expect(Services::AI::GeminiClient).to have_received(:call).with(
        prompt: anything,
        system: a_string_including('career consultant')
      )
    end
  end
end
