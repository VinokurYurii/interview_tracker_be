# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::InterviewStages', type: :request do
  path '/api/positions/{position_id}/interview_stages' do
    let(:Authorization) { '' }

    parameter name: :position_id, in: :path, type: :integer

    get 'Returns interview stages for a position' do
      tags 'InterviewStages'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'stages returned' do
        let(:signed_in_user) { create(:user) }
        let(:position) { create(:position, user: signed_in_user) }
        let(:position_id) { position.id }
        before do
          create_list(:interview_stage, 2, position: position)
          sign_in signed_in_user
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:position_id) { 1 }
        run_test!
      end
    end

    post 'Creates an interview stage' do
      tags 'InterviewStages'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :interview_stage, in: :body, schema: {
        type: :object,
        properties: {
          interview_stage: {
            type: :object,
            required: %w[stage_type],
            properties: {
              stage_type: { type: :string },
              status: { type: :string },
              scheduled_at: { type: :string, format: 'date-time' },
              calendar_link: { type: :string },
              notes: { type: :string }
            }
          }
        }
      }

      response '201', 'stage created' do
        let(:signed_in_user) { create(:user) }
        let(:position) { create(:position, user: signed_in_user) }
        let(:position_id) { position.id }
        let(:interview_stage) { { interview_stage: { stage_type: 'technical' } } }
        before { sign_in signed_in_user }

        run_test!
      end

      response '422', 'invalid params' do
        let(:signed_in_user) { create(:user) }
        let(:position) { create(:position, user: signed_in_user) }
        let(:position_id) { position.id }
        let(:interview_stage) { { interview_stage: { stage_type: '' } } }
        before { sign_in signed_in_user }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:position_id) { 1 }
        let(:interview_stage) { { interview_stage: { stage_type: 'hr' } } }
        run_test!
      end
    end
  end

  path '/api/positions/{position_id}/interview_stages/{id}' do
    let(:Authorization) { '' }

    parameter name: :position_id, in: :path, type: :integer
    parameter name: :id, in: :path, type: :integer

    get 'Returns an interview stage with feedbacks' do
      tags 'InterviewStages'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'stage returned with feedbacks' do
        let(:signed_in_user) { create(:user) }
        let(:position) { create(:position, user: signed_in_user) }
        let(:stage) { create(:interview_stage, position: position) }
        let(:position_id) { position.id }
        let(:id) { stage.id }
        before do
          create(:feedback, interview_stage: stage, feedback_type: 'self_review')
          sign_in signed_in_user
        end

        run_test!
      end

      response '404', 'not found — not owner' do
        let(:signed_in_user) { create(:user) }
        let(:other_stage) { create(:interview_stage) }
        let(:position_id) { other_stage.position_id }
        let(:id) { other_stage.id }
        before { sign_in signed_in_user }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:position_id) { 1 }
        let(:id) { 1 }
        run_test!
      end
    end

    patch 'Updates an interview stage' do
      tags 'InterviewStages'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :interview_stage, in: :body, schema: {
        type: :object,
        properties: {
          interview_stage: {
            type: :object,
            properties: {
              stage_type: { type: :string },
              status: { type: :string },
              scheduled_at: { type: :string, format: 'date-time' },
              calendar_link: { type: :string },
              notes: { type: :string }
            }
          }
        }
      }

      response '200', 'stage updated' do
        let(:signed_in_user) { create(:user) }
        let(:position) { create(:position, user: signed_in_user) }
        let(:stage) { create(:interview_stage, position: position) }
        let(:position_id) { position.id }
        let(:id) { stage.id }
        let(:interview_stage) { { interview_stage: { status: 'done', notes: 'went well' } } }
        before { sign_in signed_in_user }

        run_test!
      end

      response '404', 'not found — not owner' do
        let(:signed_in_user) { create(:user) }
        let(:other_stage) { create(:interview_stage) }
        let(:position_id) { other_stage.position_id }
        let(:id) { other_stage.id }
        let(:interview_stage) { { interview_stage: { status: 'done' } } }
        before { sign_in signed_in_user }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:position_id) { 1 }
        let(:id) { 1 }
        let(:interview_stage) { { interview_stage: { status: 'done' } } }
        run_test!
      end
    end

    delete 'Deletes an interview stage' do
      tags 'InterviewStages'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '204', 'stage deleted' do
        let(:signed_in_user) { create(:user) }
        let(:position) { create(:position, user: signed_in_user) }
        let(:stage) { create(:interview_stage, position: position) }
        let(:position_id) { position.id }
        let(:id) { stage.id }
        before { sign_in signed_in_user }

        run_test!
      end

      response '404', 'not found — not owner' do
        let(:signed_in_user) { create(:user) }
        let(:other_stage) { create(:interview_stage) }
        let(:position_id) { other_stage.position_id }
        let(:id) { other_stage.id }
        before { sign_in signed_in_user }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:position_id) { 1 }
        let(:id) { 1 }
        run_test!
      end
    end
  end
end
