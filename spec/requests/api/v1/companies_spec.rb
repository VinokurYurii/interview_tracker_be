require 'swagger_helper'

RSpec.describe 'Api::V1::Companies', type: :request do
  path '/api/companies' do
    let(:Authorization) { '' }

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

        let(:signed_in_user) { create(:user) }
        before do
          create_list(:company, 3)
          sign_in signed_in_user
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(3)
        end
      end

      response '401', 'unauthorized' do
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
        required: %w[name],
        properties: {
          company: {
            type: :object,
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

        let(:signed_in_user) { create(:user) }
        let(:company) { { company: { name: 'Google', site_link: 'https://google.com' } } }
        before { sign_in signed_in_user }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Google')
        end
      end

      response '422', 'invalid params' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }

        let(:signed_in_user) { create(:user) }
        let(:company) { { company: { name: '' } } }
        before { sign_in signed_in_user }

        run_test!
      end

      response '422', 'duplicate name' do
        let(:signed_in_user) { create(:user) }
        let!(:existing) { create(:company, name: 'Google') }
        let(:company) { { company: { name: 'google' } } }
        before { sign_in signed_in_user }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to be_present
        end
      end

      response '401', 'unauthorized' do
        let(:company) { { company: { name: 'Google' } } }

        run_test!
      end
    end
  end
end
