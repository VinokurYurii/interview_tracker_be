# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Positions', type: :request do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/positions' do
    it 'returns only positions belonging to the current user' do
      create_list(:position, 2, user: user)
      create(:position)

      get '/api/positions', headers: headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.length).to eq(2)
      expect(data.map { |p| p['user_id'] }.uniq).to eq([user.id])
    end

    it 'includes company and interview_stages in response' do
      position = create(:position, user: user)
      create(:interview_stage, position: position)

      get '/api/positions', headers: headers

      data = JSON.parse(response.body)
      expect(data.first['company']).to be_present
      expect(data.first['interview_stages']).to be_present
    end
  end

  describe 'POST /api/positions' do
    let(:valid_params) do
      { position: { title: 'Backend Engineer', description: 'desc', vacancy_url: 'https://example.com', company_id: company.id } }
    end

    it 'creates a position for the current user' do
      expect {
        post '/api/positions', params: valid_params, headers: headers, as: :json
      }.to change(Position, :count).by(1)

      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data['user_id']).to eq(user.id)
      expect(data['title']).to eq('Backend Engineer')
      expect(data['status']).to eq('active')
    end

    it 'rejects invalid params' do
      post '/api/positions', params: { position: { title: '' } }, headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'GET /api/positions/:id' do
    it 'returns the position with company data' do
      position = create(:position, user: user)

      get "/api/positions/#{position.id}", headers: headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['company']).to be_present
      expect(data['company']['id']).to eq(position.company_id)
    end

    it 'returns 403 for another user\'s position' do
      other_position = create(:position)

      get "/api/positions/#{other_position.id}", headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it 'returns 404 for non-existent position' do
      get '/api/positions/0', headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/positions/:id' do
    it 'updates position attributes' do
      position = create(:position, user: user)

      patch "/api/positions/#{position.id}", params: { position: { title: 'Updated', status: 'offer' } },
                                             headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['title']).to eq('Updated')
      expect(data['status']).to eq('offer')
    end

    it 'does not allow changing company_id on update' do
      position = create(:position, user: user, company: company)
      other_company = create(:company)

      patch "/api/positions/#{position.id}", params: { position: { company_id: other_company.id } },
                                             headers: headers, as: :json

      expect(position.reload.company_id).to eq(company.id)
    end

    it 'returns 403 for another user\'s position' do
      other_position = create(:position)

      patch "/api/positions/#{other_position.id}", params: { position: { title: 'Hack' } },
                                                   headers: headers, as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE /api/positions/:id' do
    it 'deletes the position' do
      position = create(:position, user: user)

      expect {
        delete "/api/positions/#{position.id}", headers: headers
      }.to change(Position, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 403 for another user\'s position' do
      other_position = create(:position)

      delete "/api/positions/#{other_position.id}", headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end
end
