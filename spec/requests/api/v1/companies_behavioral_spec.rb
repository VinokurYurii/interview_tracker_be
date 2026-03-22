# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Companies', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /api/companies' do
    it 'returns all companies' do
      create_list(:company, 3)

      get '/api/companies'

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.length).to eq(3)
    end

    it 'returns companies visible to all users' do
      create(:company, name: 'Shared Corp')
      other_user = create(:user)
      sign_in other_user

      get '/api/companies'

      data = JSON.parse(response.body)
      expect(data.length).to eq(1)
      expect(data.first['name']).to eq('Shared Corp')
    end
  end

  describe 'POST /api/companies' do
    it 'creates a company and returns it' do
      expect {
        post '/api/companies', params: { company: { name: 'Google', site_link: 'https://google.com' } }, as: :json
      }.to change(Company, :count).by(1)

      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data['name']).to eq('Google')
      expect(data['site_link']).to eq('https://google.com')
    end

    it 'rejects duplicate company names (case-insensitive)' do
      create(:company, name: 'Google')

      post '/api/companies', params: { company: { name: 'google' } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      data = JSON.parse(response.body)
      expect(data['errors']).to be_present
    end

    it 'rejects blank name' do
      post '/api/companies', params: { company: { name: '' } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
