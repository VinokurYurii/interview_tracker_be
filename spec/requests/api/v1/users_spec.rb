require 'swagger_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  path '/api/user' do
    # Placeholder — replaced by JWT token once auth is implemented
    let(:Authorization) { '' }

    get 'Returns the current user' do
      tags 'User'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'user returned' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   required: %w[id first_name last_name email],
                   properties: {
                     id: { type: :integer },
                     first_name: { type: :string },
                     last_name: { type: :string },
                     email: { type: :string }
                   }
                 }
               }

        let(:signed_in_user) { create(:user) }
        before { sign_in signed_in_user }

        run_test!
      end

      response '401', 'unauthorized' do
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
               properties: {
                 data: {
                   type: :object,
                   required: %w[id first_name last_name email],
                   properties: {
                     id: { type: :integer },
                     first_name: { type: :string },
                     last_name: { type: :string },
                     email: { type: :string }
                   }
                 }
               }

        let(:signed_in_user) { create(:user) }
        let(:user) { { user: { first_name: 'Jane' } } }
        before { sign_in signed_in_user }

        run_test!
      end

      response '422', 'invalid params' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }

        let(:signed_in_user) { create(:user) }
        let(:user) { { user: { first_name: '' } } }
        before { sign_in signed_in_user }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:user) { { user: { first_name: 'Jane' } } }

        run_test!
      end
    end
  end
end
