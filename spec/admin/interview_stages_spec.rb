# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin InterviewStages', type: :request, admin: true do
  let(:admin_user) { create(:admin_user) }

  before { admin_sign_in(admin_user) }

  let!(:user) { create(:user) }
  let!(:company) { create(:company) }
  let!(:position) { create(:position, user: user, company: company) }
  let!(:stage) { create(:interview_stage, position: position) }
  let!(:feedback) { create(:feedback, interview_stage: stage) }

  describe 'GET /admin/interview_stages' do
    it 'renders the index page' do
      get '/admin/interview_stages'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/interview_stages/:id' do
    it 'renders the show page with feedbacks panel' do
      get "/admin/interview_stages/#{stage.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/interview_stages/new' do
    it 'renders the new form' do
      get '/admin/interview_stages/new'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/interview_stages/:id/edit' do
    it 'renders the edit form' do
      get "/admin/interview_stages/#{stage.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /admin/interview_stages' do
    it 'creates a stage' do
      expect {
        post '/admin/interview_stages', params: { interview_stage: { position_id: position.id, stage_type: 'technical', status: 'planned' } }
      }.to change(InterviewStage, :count).by(1)
    end
  end

  describe 'PATCH /admin/interview_stages/:id' do
    it 'updates a stage' do
      patch "/admin/interview_stages/#{stage.id}", params: { interview_stage: { status: 'done' } }
      expect(stage.reload.status).to eq('done')
    end
  end
end
