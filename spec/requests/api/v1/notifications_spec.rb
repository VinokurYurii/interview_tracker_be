# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Notifications', type: :request do
  path '/api/notifications' do
    let(:signed_in_user) { create(:user) }
    let(:Authorization) { "Bearer #{auth_headers_for(signed_in_user)['Authorization'].split.last}" }

    get 'Returns notifications for current user' do
      tags 'Notifications'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'notifications returned' do
        schema type: :array,
               items: {
                 type: :object,
                 required: %w[id title body created_at notifiable_id notifiable_type],
                 properties: {
                   id: { type: :integer },
                   title: { type: :string },
                   body: { type: :string },
                   read_at: { type: :string, format: 'date-time', nullable: true },
                   created_at: { type: :string, format: 'date-time' },
                   notifiable_id: { type: :integer },
                   notifiable_type: { type: :string }
                 }
               }

        before { create_list(:notification, 2, user: signed_in_user) }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }

        run_test!
      end
    end
  end

  path '/api/notifications/{id}/mark_read' do
    let(:signed_in_user) { create(:user) }
    let(:Authorization) { "Bearer #{auth_headers_for(signed_in_user)['Authorization'].split.last}" }

    parameter name: :id, in: :path, type: :integer

    post 'Marks a notification as read' do
      tags 'Notifications'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'notification marked as read' do
        schema type: :object,
               required: %w[id title body created_at notifiable_id notifiable_type],
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 body: { type: :string },
                 read_at: { type: :string, format: 'date-time' },
                 created_at: { type: :string, format: 'date-time' },
                 notifiable_id: { type: :integer },
                 notifiable_type: { type: :string }
               }

        let(:notification) { create(:notification, user: signed_in_user) }
        let(:id) { notification.id }

        run_test!
      end

      response '404', 'not found or not owner' do
        let(:id) { 0 }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:id) { 1 }

        run_test!
      end
    end
  end
end
