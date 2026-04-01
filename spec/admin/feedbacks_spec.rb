# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Feedbacks', type: :request, admin: true do
  let(:admin_user) { create(:admin_user) }

  before { admin_sign_in(admin_user) }

  let!(:user) { create(:user) }
  let!(:company) { create(:company) }
  let!(:position) { create(:position, user: user, company: company) }
  let!(:stage) { create(:interview_stage, position: position) }
  let!(:feedback) { create(:feedback, interview_stage: stage) }

  describe 'GET /admin/feedbacks' do
    it 'renders the index page' do
      get '/admin/feedbacks'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/feedbacks/:id' do
    it 'renders the show page' do
      get "/admin/feedbacks/#{feedback.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/feedbacks/new' do
    it 'renders the new form' do
      get '/admin/feedbacks/new'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/feedbacks/:id/edit' do
    it 'renders the edit form' do
      get "/admin/feedbacks/#{feedback.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /admin/feedbacks' do
    it 'creates a feedback' do
      new_stage = create(:interview_stage, position: position, stage_type: 'technical')
      expect {
        post '/admin/feedbacks', params: { feedback: { interview_stage_id: new_stage.id, feedback_type: 'self_review', content: 'Great interview' } }
      }.to change(Feedback, :count).by(1)
    end
  end

  describe 'PATCH /admin/feedbacks/:id' do
    it 'updates a feedback' do
      patch "/admin/feedbacks/#{feedback.id}", params: { feedback: { content: 'Updated content' } }
      expect(feedback.reload.content).to eq('Updated content')
    end
  end
end
