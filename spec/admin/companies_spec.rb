# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Companies', type: :request, admin: true do
  let(:admin_user) { create(:admin_user) }

  before { admin_sign_in(admin_user) }

  let!(:user) { create(:user) }
  let!(:company) { create(:company) }
  let!(:position) { create(:position, user: user, company: company) }

  describe 'GET /admin/companies' do
    it 'renders the index page' do
      get '/admin/companies'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/companies/:id' do
    it 'renders the show page with positions panel' do
      get "/admin/companies/#{company.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/companies/new' do
    it 'renders the new form' do
      get '/admin/companies/new'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/companies/:id/edit' do
    it 'renders the edit form' do
      get "/admin/companies/#{company.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /admin/companies' do
    it 'creates a company' do
      expect {
        post '/admin/companies', params: { company: { name: 'New Corp', site_link: 'https://new.com' } }
      }.to change(Company, :count).by(1)
    end
  end

  describe 'PATCH /admin/companies/:id' do
    it 'updates a company' do
      patch "/admin/companies/#{company.id}", params: { company: { name: 'Updated Corp' } }
      expect(company.reload.name).to eq('Updated Corp')
    end
  end
end
