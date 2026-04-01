# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Positions', type: :request, admin: true do
  let(:admin_user) { create(:admin_user) }

  before { admin_sign_in(admin_user) }

  let!(:user) { create(:user) }
  let!(:company) { create(:company) }
  let!(:position) { create(:position, user: user, company: company) }
  let!(:stage) { create(:interview_stage, position: position) }

  describe 'GET /admin/positions' do
    it 'renders the index page' do
      get '/admin/positions'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/positions/:id' do
    it 'renders the show page with stages panel' do
      get "/admin/positions/#{position.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/positions/new' do
    it 'renders the new form' do
      get '/admin/positions/new'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/positions/:id/edit' do
    it 'renders the edit form' do
      get "/admin/positions/#{position.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /admin/positions' do
    it 'creates a position' do
      expect {
        post '/admin/positions', params: { position: { title: 'New Role', status: 'active', user_id: user.id, company_id: company.id } }
      }.to change(Position, :count).by(1)
    end
  end

  describe 'PATCH /admin/positions/:id' do
    it 'updates a position' do
      patch "/admin/positions/#{position.id}", params: { position: { title: 'Updated Role' } }
      expect(position.reload.title).to eq('Updated Role')
    end
  end
end
