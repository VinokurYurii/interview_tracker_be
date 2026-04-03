# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Resumes', type: :request do
  path '/api/resumes' do
    let(:signed_in_user) { create(:user) }
    let(:Authorization) { "Bearer #{auth_headers_for(signed_in_user)['Authorization'].split.last}" }

    get 'Returns resumes for current user' do
      tags 'Resumes'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'resumes returned' do
        schema type: :array,
               items: {
                 type: :object,
                 required: %w[id name],
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   file_url: { type: :string, nullable: true },
                   created_at: { type: :string },
                   updated_at: { type: :string }
                 }
               }

        before { create_list(:resume, 2, user: signed_in_user) }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }

        run_test!
      end
    end

    post 'Creates a resume' do
      tags 'Resumes'
      consumes 'multipart/form-data'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: 'resume[name]', in: :formData, type: :string, required: true
      parameter name: 'resume[file]', in: :formData, type: :file, required: false

      response '201', 'resume created' do
        schema type: :object,
               required: %w[id name],
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 file_url: { type: :string, nullable: true },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }

        let(:'resume[name]') { 'Backend CV' }
        let(:'resume[file]') { Rack::Test::UploadedFile.new(StringIO.new('%PDF-1.4 fake'), 'application/pdf', true, original_filename: 'cv.pdf') }

        run_test!
      end

      response '422', 'invalid params' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }

        let(:'resume[name]') { '' }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:'resume[name]') { 'CV' }

        run_test!
      end
    end
  end

  path '/api/resumes/{id}' do
    let(:signed_in_user) { create(:user) }
    let(:Authorization) { "Bearer #{auth_headers_for(signed_in_user)['Authorization'].split.last}" }

    parameter name: :id, in: :path, type: :integer

    get 'Returns a resume' do
      tags 'Resumes'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'resume returned' do
        schema type: :object,
               required: %w[id name],
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 file_url: { type: :string, nullable: true },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }

        let(:record) { create(:resume, :with_file, user: signed_in_user) }
        let(:id) { record.id }

        run_test!
      end

      response '403', 'forbidden — not owner' do
        let(:other_resume) { create(:resume) }
        let(:id) { other_resume.id }

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

    patch 'Updates a resume' do
      tags 'Resumes'
      consumes 'multipart/form-data'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: 'resume[name]', in: :formData, type: :string, required: false
      parameter name: 'resume[file]', in: :formData, type: :file, required: false

      response '200', 'resume updated' do
        schema type: :object,
               required: %w[id name],
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 file_url: { type: :string, nullable: true },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }

        let(:record) { create(:resume, user: signed_in_user) }
        let(:id) { record.id }
        let(:'resume[name]') { 'Updated CV' }

        run_test!
      end

      response '422', 'invalid params' do
        let(:record) { create(:resume, user: signed_in_user) }
        let(:id) { record.id }
        let(:'resume[name]') { '' }

        run_test!
      end

      response '403', 'forbidden — not owner' do
        let(:other_resume) { create(:resume) }
        let(:id) { other_resume.id }
        let(:'resume[name]') { 'Hack' }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:id) { 1 }
        let(:'resume[name]') { 'x' }

        run_test!
      end
    end

    delete 'Deletes a resume' do
      tags 'Resumes'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '204', 'resume deleted (no linked positions)' do
        let(:record) { create(:resume, user: signed_in_user) }
        let(:id) { record.id }

        run_test!
      end

      response '200', 'file removed but record retained (has linked positions)' do
        schema type: :object,
               properties: {
                 warning: { type: :string },
                 resume: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     file_url: { type: :string, nullable: true }
                   }
                 }
               }

        let(:record) { create(:resume, :with_file, user: signed_in_user) }
        let(:id) { record.id }

        before { create(:position, resume: record, user: signed_in_user) }

        run_test!
      end

      response '403', 'forbidden — not owner' do
        let(:other_resume) { create(:resume) }
        let(:id) { other_resume.id }

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
