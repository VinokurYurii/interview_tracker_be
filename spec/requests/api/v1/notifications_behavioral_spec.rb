# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Notifications', type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/notifications' do
    it 'returns only notifications belonging to the current user' do
      create_list(:notification, 2, user: user)
      create(:notification)

      get '/api/notifications', headers: headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.length).to eq(2)
    end

    it 'returns notifications ordered by created_at desc' do
      old = create(:notification, user: user, created_at: 2.days.ago)
      new_one = create(:notification, user: user, created_at: 1.hour.ago)

      get '/api/notifications', headers: headers

      data = JSON.parse(response.body)
      expect(data.map { |n| n['id'] }).to eq([new_one.id, old.id])
    end

    it 'returns notification attributes including notifiable info' do
      position = create(:position, user: user)
      create(:notification, user: user, notifiable: position)

      get '/api/notifications', headers: headers

      data = JSON.parse(response.body)
      expect(data.first).to include('id', 'title', 'body', 'read_at', 'created_at')
    end
  end

  describe 'POST /api/notifications/:id/mark_read' do
    it 'marks the notification as read' do
      notification = create(:notification, user: user)

      post "/api/notifications/#{notification.id}/mark_read", headers: headers

      expect(response).to have_http_status(:ok)
      expect(notification.reload.read_at).to be_present
    end

    it 'returns the updated notification' do
      notification = create(:notification, user: user)

      post "/api/notifications/#{notification.id}/mark_read", headers: headers

      data = JSON.parse(response.body)
      expect(data['read_at']).to be_present
    end

    it 'returns 404 for another user\'s notification' do
      other_notification = create(:notification)

      post "/api/notifications/#{other_notification.id}/mark_read", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for non-existent notification' do
      post '/api/notifications/0/mark_read', headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
