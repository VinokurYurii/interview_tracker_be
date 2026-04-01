# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Users', type: :request, admin: true do
  let(:admin_user) { create(:admin_user) }

  before { admin_sign_in(admin_user) }

  let!(:user) { create(:user) }
  let!(:company) { create(:company) }
  let!(:position) { create(:position, user: user, company: company) }

  describe 'GET /admin/users' do
    it 'renders the index page' do
      get '/admin/users'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/users/:id' do
    it 'renders the show page with positions panel' do
      get "/admin/users/#{user.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/users/new' do
    it 'renders the new form' do
      get '/admin/users/new'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/users/:id/edit' do
    it 'renders the edit form' do
      get "/admin/users/#{user.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /admin/users' do
    it 'creates a user' do
      expect {
        post '/admin/users', params: { user: { email: 'new@example.com', first_name: 'Jane', last_name: 'Doe', password: 'password123', password_confirmation: 'password123' } }
      }.to change(User, :count).by(1)
    end
  end

  describe 'PATCH /admin/users/:id' do
    it 'updates user without password' do
      patch "/admin/users/#{user.id}", params: { user: { first_name: 'Updated' } }
      expect(user.reload.first_name).to eq('Updated')
    end

    it 'updates user with new password' do
      patch "/admin/users/#{user.id}", params: { user: { password: 'newpassword123', password_confirmation: 'newpassword123' } }
      expect(response).to have_http_status(:redirect)
    end
  end
end
