# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Feedbacks', type: :request do
  let(:user) { create(:user) }
  let(:position) { create(:position, user: user) }
  let(:stage) { create(:interview_stage, position: position) }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/positions/:position_id/interview_stages/:interview_stage_id/feedbacks' do
    it 'returns feedbacks for the stage' do
      create(:feedback, interview_stage: stage, feedback_type: 'self_review')
      create(:feedback, interview_stage: stage, feedback_type: 'company')

      get "/api/positions/#{position.id}/interview_stages/#{stage.id}/feedbacks", headers: headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.length).to eq(2)
    end

    it 'returns 404 for another user\'s stage' do
      other_stage = create(:interview_stage)

      get "/api/positions/#{other_stage.position_id}/interview_stages/#{other_stage.id}/feedbacks", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/positions/:position_id/interview_stages/:interview_stage_id/feedbacks' do
    it 'creates a feedback' do
      expect {
        post "/api/positions/#{position.id}/interview_stages/#{stage.id}/feedbacks",
             params: { feedback: { feedback_type: 'self_review', content: 'It went well' } },
             headers: headers, as: :json
      }.to change(Feedback, :count).by(1)

      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data['feedback_type']).to eq('self_review')
      expect(data['content']).to eq('It went well')
    end

    it 'rejects duplicate feedback_type for the same stage' do
      create(:feedback, interview_stage: stage, feedback_type: 'self_review')

      post "/api/positions/#{position.id}/interview_stages/#{stage.id}/feedbacks",
           params: { feedback: { feedback_type: 'self_review', content: 'duplicate' } },
           headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      data = JSON.parse(response.body)
      expect(data['errors']).to be_present
    end

    it 'rejects blank content' do
      post "/api/positions/#{position.id}/interview_stages/#{stage.id}/feedbacks",
           params: { feedback: { feedback_type: 'company', content: '' } },
           headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns 404 for another user\'s stage' do
      other_stage = create(:interview_stage)

      post "/api/positions/#{other_stage.position_id}/interview_stages/#{other_stage.id}/feedbacks",
           params: { feedback: { feedback_type: 'self_review', content: 'hack' } },
           headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/positions/:position_id/interview_stages/:interview_stage_id/feedbacks/:id' do
    it 'updates feedback content' do
      feedback = create(:feedback, interview_stage: stage, feedback_type: 'self_review')

      patch "/api/positions/#{position.id}/interview_stages/#{stage.id}/feedbacks/#{feedback.id}",
            params: { feedback: { content: 'Updated content' } },
            headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['content']).to eq('Updated content')
      expect(feedback.reload.content).to eq('Updated content')
    end

    it 'returns 404 for another user\'s feedback' do
      other_feedback = create(:feedback)

      patch "/api/positions/#{other_feedback.interview_stage.position_id}/interview_stages/#{other_feedback.interview_stage_id}/feedbacks/#{other_feedback.id}",
            params: { feedback: { content: 'hack' } },
            headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/positions/:position_id/interview_stages/:interview_stage_id/feedbacks/:id' do
    it 'deletes the feedback' do
      feedback = create(:feedback, interview_stage: stage, feedback_type: 'self_review')

      expect {
        delete "/api/positions/#{position.id}/interview_stages/#{stage.id}/feedbacks/#{feedback.id}", headers: headers
      }.to change(Feedback, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 for another user\'s feedback' do
      other_feedback = create(:feedback)

      delete "/api/positions/#{other_feedback.interview_stage.position_id}/interview_stages/#{other_feedback.interview_stage_id}/feedbacks/#{other_feedback.id}",
             headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
