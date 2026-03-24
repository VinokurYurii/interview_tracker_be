# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Positions', type: :request do
  path '/api/positions' do
    let(:signed_in_user) { create(:user) }
    let(:Authorization) { "Bearer #{auth_headers_for(signed_in_user)['Authorization'].split.last}" }

    get 'Returns positions for current user' do
      tags 'Positions'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'positions returned' do
        schema type: :array,
               items: {
                 type: :object,
                 required: %w[id title status company_id user_id],
                 properties: {
                   id: { type: :integer },
                   title: { type: :string },
                   description: { type: :string },
                   vacancy_url: { type: :string },
                   status: { type: :string },
                   company_id: { type: :integer },
                   user_id: { type: :integer }
                 }
               }

        before { create_list(:position, 2, user: signed_in_user) }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }

        run_test!
      end
    end

    post 'Creates a position' do
      tags 'Positions'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :position, in: :body, schema: {
        type: :object,
        required: %w[position],
        properties: {
          position: {
            type: :object,
            required: %w[title description vacancy_url company_id],
            properties: {
              title: { type: :string },
              description: { type: :string },
              vacancy_url: { type: :string },
              status: { type: :string },
              company_id: { type: :integer }
            }
          }
        }
      }

      response '201', 'position created' do
        schema type: :object,
               required: %w[id title status],
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 status: { type: :string },
                 company_id: { type: :integer },
                 user_id: { type: :integer }
               }

        let(:company) { create(:company) }
        let(:position) do
          { position: { title: 'Backend Engineer', description: 'desc', vacancy_url: 'https://example.com', company_id: company.id } }
        end

        run_test!
      end

      response '422', 'invalid params' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }

        let(:company) { create(:company) }
        let(:position) { { position: { title: '', description: 'desc', vacancy_url: 'https://example.com', company_id: company.id } } }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:position) { { position: { title: 'Backend Engineer' } } }

        run_test!
      end
    end
  end

  path '/api/positions/{id}' do
    let(:signed_in_user) { create(:user) }
    let(:Authorization) { "Bearer #{auth_headers_for(signed_in_user)['Authorization'].split.last}" }

    parameter name: :id, in: :path, type: :integer

    get 'Returns a position' do
      tags 'Positions'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'position returned with company' do
        schema type: :object,
               required: %w[id title status company],
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 status: { type: :string },
                 company_id: { type: :integer },
                 company: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string }
                   }
                 }
               }

        let(:record) { create(:position, user: signed_in_user) }
        let(:id) { record.id }

        run_test!
      end

      response '403', 'forbidden — not owner' do
        let(:other_position) { create(:position) }
        let(:id) { other_position.id }

        run_test!
      end

      response '404', 'not found' do
        let(:id) { 0 }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:id) { 1 }

        run_test!
      end
    end

    patch 'Updates a position' do
      tags 'Positions'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :position, in: :body, schema: {
        type: :object,
        properties: {
          position: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              vacancy_url: { type: :string },
              status: { type: :string }
            }
          }
        }
      }

      response '200', 'position updated' do
        let(:record) { create(:position, user: signed_in_user) }
        let(:id) { record.id }
        let(:position) { { position: { title: 'Updated Title' } } }

        run_test!
      end

      response '422', 'invalid params' do
        let(:record) { create(:position, user: signed_in_user) }
        let(:id) { record.id }
        let(:position) { { position: { title: '' } } }

        run_test!
      end

      response '403', 'forbidden — not owner' do
        let(:other_position) { create(:position) }
        let(:id) { other_position.id }
        let(:position) { { position: { title: 'Hack' } } }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:id) { 1 }
        let(:position) { { position: { title: 'x' } } }

        run_test!
      end
    end

    delete 'Deletes a position' do
      tags 'Positions'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '204', 'position deleted' do
        let(:record) { create(:position, user: signed_in_user) }
        let(:id) { record.id }

        run_test!
      end

      response '403', 'forbidden — not owner' do
        let(:other_position) { create(:position) }
        let(:id) { other_position.id }

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
