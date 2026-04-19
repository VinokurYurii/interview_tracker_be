# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Auth::Sessions', type: :request do
  path '/api/auth/sign_in' do
    post 'Signs in a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      security []

      parameter name: :user, in: :body, schema: {
        type: :object,
        required: %w[user],
        properties: {
          user: {
            type: :object,
            required: %w[email password],
            properties: {
              email: { type: :string },
              password: { type: :string }
            }
          }
        }
      }

      response '200', 'signed in — JWT token returned in Authorization header' do
        schema type: :object,
               required: %w[id first_name last_name email unread_notifications_count],
               properties: {
                 id: { type: :integer },
                 first_name: { type: :string },
                 last_name: { type: :string },
                 email: { type: :string },
                 unread_notifications_count: { type: :integer }
               }

        let(:existing_user) { create(:user, password: 'password123') }
        let(:user) { { user: { email: existing_user.email, password: 'password123' } } }

        run_test! do |response|
          expect(response.headers['Authorization']).to be_present
        end
      end

      response '401', 'invalid credentials' do
        let(:user) { { user: { email: 'wrong@example.com', password: 'wrong' } } }

        run_test!
      end
    end
  end

  path '/api/auth/sign_out' do
    delete 'Signs out a user' do
      tags 'Authentication'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'signed out — token revoked' do
        let(:existing_user) { create(:user) }
        let(:Authorization) { "Bearer #{auth_headers_for(existing_user)['Authorization'].split.last}" }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }

        run_test!
      end
    end
  end
end
