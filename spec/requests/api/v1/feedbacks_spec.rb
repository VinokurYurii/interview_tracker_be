# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Feedbacks', type: :request do
  path '/api/positions/{position_id}/interview_stages/{interview_stage_id}/feedbacks' do
    let(:signed_in_user) { create(:user) }
    let(:Authorization) { "Bearer #{auth_headers_for(signed_in_user)['Authorization'].split.last}" }

    parameter name: :position_id, in: :path, type: :integer
    parameter name: :interview_stage_id, in: :path, type: :integer

    get 'Returns feedbacks for an interview stage' do
      tags 'Feedbacks'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'feedbacks returned' do
        let(:position) { create(:position, user: signed_in_user) }
        let(:stage) { create(:interview_stage, position: position) }
        let(:position_id) { position.id }
        let(:interview_stage_id) { stage.id }
        before do
          create(:feedback, interview_stage: stage, feedback_type: 'self_review')
          create(:feedback, interview_stage: stage, feedback_type: 'company')
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:position_id) { 1 }
        let(:interview_stage_id) { 1 }

        run_test!
      end
    end

    post 'Creates a feedback' do
      tags 'Feedbacks'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :feedback, in: :body, schema: {
        type: :object,
        properties: {
          feedback: {
            type: :object,
            required: %w[feedback_type content],
            properties: {
              feedback_type: { type: :string, enum: %w[self_review company] },
              content: { type: :string }
            }
          }
        }
      }

      response '201', 'feedback created' do
        let(:position) { create(:position, user: signed_in_user) }
        let(:stage) { create(:interview_stage, position: position) }
        let(:position_id) { position.id }
        let(:interview_stage_id) { stage.id }
        let(:feedback) { { feedback: { feedback_type: 'self_review', content: 'It went well' } } }

        run_test!
      end

      response '422', 'invalid params' do
        let(:position) { create(:position, user: signed_in_user) }
        let(:stage) { create(:interview_stage, position: position) }
        let(:position_id) { position.id }
        let(:interview_stage_id) { stage.id }
        let(:feedback) { { feedback: { feedback_type: 'company', content: '' } } }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:position_id) { 1 }
        let(:interview_stage_id) { 1 }
        let(:feedback) { { feedback: { feedback_type: 'self_review', content: 'x' } } }

        run_test!
      end
    end
  end

  path '/api/positions/{position_id}/interview_stages/{interview_stage_id}/feedbacks/{id}' do
    let(:signed_in_user) { create(:user) }
    let(:Authorization) { "Bearer #{auth_headers_for(signed_in_user)['Authorization'].split.last}" }

    parameter name: :position_id, in: :path, type: :integer
    parameter name: :interview_stage_id, in: :path, type: :integer
    parameter name: :id, in: :path, type: :integer

    patch 'Updates a feedback' do
      tags 'Feedbacks'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :feedback, in: :body, schema: {
        type: :object,
        properties: {
          feedback: {
            type: :object,
            properties: {
              content: { type: :string }
            }
          }
        }
      }

      response '200', 'feedback updated' do
        let(:position) { create(:position, user: signed_in_user) }
        let(:stage) { create(:interview_stage, position: position) }
        let(:record) { create(:feedback, interview_stage: stage, feedback_type: 'self_review') }
        let(:position_id) { position.id }
        let(:interview_stage_id) { stage.id }
        let(:id) { record.id }
        let(:feedback) { { feedback: { content: 'Updated content' } } }

        run_test!
      end

      response '404', 'stage not found — belongs to another user' do
        let(:other_feedback) { create(:feedback) }
        let(:position_id) { other_feedback.interview_stage.position_id }
        let(:interview_stage_id) { other_feedback.interview_stage_id }
        let(:id) { other_feedback.id }
        let(:feedback) { { feedback: { content: 'hack' } } }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:position_id) { 1 }
        let(:interview_stage_id) { 1 }
        let(:id) { 1 }
        let(:feedback) { { feedback: { content: 'x' } } }

        run_test!
      end
    end

    delete 'Deletes a feedback' do
      tags 'Feedbacks'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '204', 'feedback deleted' do
        let(:position) { create(:position, user: signed_in_user) }
        let(:stage) { create(:interview_stage, position: position) }
        let(:record) { create(:feedback, interview_stage: stage, feedback_type: 'self_review') }
        let(:position_id) { position.id }
        let(:interview_stage_id) { stage.id }
        let(:id) { record.id }

        run_test!
      end

      response '404', 'stage not found — belongs to another user' do
        let(:other_feedback) { create(:feedback) }
        let(:position_id) { other_feedback.interview_stage.position_id }
        let(:interview_stage_id) { other_feedback.interview_stage_id }
        let(:id) { other_feedback.id }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { '' }
        let(:position_id) { 1 }
        let(:interview_stage_id) { 1 }
        let(:id) { 1 }

        run_test!
      end
    end
  end
end
