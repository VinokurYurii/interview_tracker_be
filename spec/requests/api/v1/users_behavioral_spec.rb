# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let(:user) { create(:user, first_name: 'John', last_name: 'Doe') }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/user' do
    context 'when authenticated' do
      it 'returns current user data' do
        get '/api/user', headers: headers

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['id']).to eq(user.id)
        expect(data['first_name']).to eq('John')
        expect(data['last_name']).to eq('Doe')
        expect(data['email']).to eq(user.email)
      end
    end
  end

  describe 'PATCH /api/user' do
    context 'when authenticated' do
      it 'updates user attributes and returns updated data' do
        patch '/api/user', params: { user: { first_name: 'Jane', last_name: 'Smith' } }, headers: headers, as: :json

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['first_name']).to eq('Jane')
        expect(data['last_name']).to eq('Smith')
        expect(user.reload.first_name).to eq('Jane')
      end

      it 'returns errors for invalid params' do
        patch '/api/user', params: { user: { first_name: '' } }, headers: headers, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        data = JSON.parse(response.body)
        expect(data['errors']).to be_present
      end
    end
  end
end
