# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  path '/api/user' do
    let(:signed_in_user) { create(:user) }
    let(:Authorization) { "Bearer #{auth_headers_for(signed_in_user)['Authorization'].split.last}" }

    get 'Returns the current user' do
      tags 'User'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'user returned' do
        schema type: :object,
               required: %w[id first_name last_name email],
               properties: {
                 id: { type: :integer },
                 first_name: { type: :string },
                 last_name: { type: :string },
                 email: { type: :string }
               }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }

        run_test!
      end
    end

    patch 'Updates the current user' do
      tags 'User'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string }
            }
          }
        }
      }

      response '200', 'user updated' do
        schema type: :object,
               required: %w[id first_name last_name email],
               properties: {
                 id: { type: :integer },
                 first_name: { type: :string },
                 last_name: { type: :string },
                 email: { type: :string }
               }

        let(:user) { { user: { first_name: 'Jane' } } }

        run_test!
      end

      response '422', 'invalid params' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }

        let(:user) { { user: { first_name: '' } } }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:user) { { user: { first_name: 'Jane' } } }

        run_test!
      end
    end
  end
end
