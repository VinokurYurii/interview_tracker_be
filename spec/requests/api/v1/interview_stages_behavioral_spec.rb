# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::InterviewStages', type: :request do
  let(:user) { create(:user) }
  let(:position) { create(:position, user: user) }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/positions/:position_id/interview_stages' do
    it 'returns stages for the given position' do
      create_list(:interview_stage, 2, position: position)

      get "/api/positions/#{position.id}/interview_stages", headers: headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.length).to eq(2)
    end

    it 'returns only stages belonging to the current user' do
      create(:interview_stage, position: position)
      other_position = create(:position)
      create(:interview_stage, position: other_position)

      get "/api/positions/#{position.id}/interview_stages", headers: headers

      data = JSON.parse(response.body)
      expect(data.length).to eq(1)
    end

    it 'returns 404 for another user\'s position' do
      other_position = create(:position)

      get "/api/positions/#{other_position.id}/interview_stages", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/positions/:position_id/interview_stages' do
    it 'creates a stage with default status planned' do
      expect {
        post "/api/positions/#{position.id}/interview_stages",
             params: { interview_stage: { stage_type: 'technical' } }, headers: headers, as: :json
      }.to change(InterviewStage, :count).by(1)

      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data['stage_type']).to eq('technical')
      expect(data['status']).to eq('planned')
    end

    it 'rejects invalid params' do
      post "/api/positions/#{position.id}/interview_stages",
           params: { interview_stage: { stage_type: '' } }, headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns 404 when creating stage for another user\'s position' do
      other_position = create(:position)

      post "/api/positions/#{other_position.id}/interview_stages",
           params: { interview_stage: { stage_type: 'hr' } }, headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/positions/:position_id/interview_stages/:id' do
    it 'returns the stage with feedbacks' do
      stage = create(:interview_stage, position: position)
      create(:feedback, interview_stage: stage, feedback_type: 'self_review')

      get "/api/positions/#{position.id}/interview_stages/#{stage.id}", headers: headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['feedbacks']).to be_present
      expect(data['feedbacks'].length).to eq(1)
    end

    it 'returns 404 for another user\'s stage' do
      other_stage = create(:interview_stage)

      get "/api/positions/#{other_stage.position_id}/interview_stages/#{other_stage.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/positions/:position_id/interview_stages/:id' do
    it 'updates stage attributes' do
      stage = create(:interview_stage, position: position)

      patch "/api/positions/#{position.id}/interview_stages/#{stage.id}",
            params: { interview_stage: { status: 'done', notes: 'went well' } }, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['status']).to eq('done')
      expect(data['notes']).to eq('went well')
    end

    it 'returns 404 for another user\'s stage' do
      other_stage = create(:interview_stage)

      patch "/api/positions/#{other_stage.position_id}/interview_stages/#{other_stage.id}",
            params: { interview_stage: { status: 'done' } }, headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/positions/:position_id/interview_stages/:id' do
    it 'deletes the stage' do
      stage = create(:interview_stage, position: position)

      expect {
        delete "/api/positions/#{position.id}/interview_stages/#{stage.id}", headers: headers
      }.to change(InterviewStage, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 for another user\'s stage' do
      other_stage = create(:interview_stage)

      delete "/api/positions/#{other_stage.position_id}/interview_stages/#{other_stage.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
