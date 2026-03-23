# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Auth::Registrations', type: :request do
  path '/api/auth/sign_up' do
    post 'Registers a new user' do
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
            required: %w[email password password_confirmation first_name last_name],
            properties: {
              email: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string },
              first_name: { type: :string },
              last_name: { type: :string }
            }
          }
        }
      }

      response '201', 'user registered — JWT token returned in Authorization header' do
        schema type: :object,
               required: %w[id first_name last_name email],
               properties: {
                 id: { type: :integer },
                 first_name: { type: :string },
                 last_name: { type: :string },
                 email: { type: :string }
               }

        let(:user) do
          { user: { email: 'new@example.com', password: 'password123',
                    password_confirmation: 'password123', first_name: 'John', last_name: 'Doe' } }
        end

        run_test! do |response|
          expect(response.headers['Authorization']).to be_present
        end
      end

      response '422', 'invalid params' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }

        let(:user) { { user: { email: '', password: '', first_name: '', last_name: '' } } }

        run_test!
      end
    end
  end
end
