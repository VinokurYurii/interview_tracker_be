# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Companies', type: :request do
  path '/api/companies' do
    let(:signed_in_user) { create(:user) }
    let(:Authorization) { "Bearer #{auth_headers_for(signed_in_user)['Authorization'].split.last}" }

    get 'Returns list of all companies' do
      tags 'Companies'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'companies returned' do
        schema type: :array,
               items: {
                 type: :object,
                 required: %w[id name],
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   site_link: { type: :string, nullable: true }
                 }
               }

        before { create_list(:company, 3) }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }

        run_test!
      end
    end

    post 'Creates a company' do
      tags 'Companies'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :company, in: :body, schema: {
        type: :object,
        properties: {
          company: {
            type: :object,
            required: %w[name],
            properties: {
              name: { type: :string },
              site_link: { type: :string }
            }
          }
        }
      }

      response '201', 'company created' do
        schema type: :object,
               required: %w[id name],
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 site_link: { type: :string, nullable: true }
               }

        let(:company) { { company: { name: 'Google', site_link: 'https://google.com' } } }

        run_test!
      end

      response '422', 'invalid params' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }

        let(:company) { { company: { name: '' } } }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:company) { { company: { name: 'Google' } } }

        run_test!
      end
    end
  end
end
