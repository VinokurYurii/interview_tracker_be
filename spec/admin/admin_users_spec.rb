# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin AdminUsers', type: :request, admin: true do
  let(:admin_user) { create(:admin_user) }

  before { admin_sign_in(admin_user) }

  describe 'GET /admin/admin_users' do
    it 'renders the index page' do
      get '/admin/admin_users'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/admin_users/new' do
    it 'renders the new form' do
      get '/admin/admin_users/new'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/admin_users/:id/edit' do
    it 'renders the edit form' do
      get "/admin/admin_users/#{admin_user.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /admin/admin_users' do
    it 'creates an admin user' do
      expect {
        post '/admin/admin_users', params: { admin_user: { email: 'newadmin@example.com', password: 'password123' } }
      }.to change(AdminUser, :count).by(1)
    end
  end
end
