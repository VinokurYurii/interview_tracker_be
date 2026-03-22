# frozen_string_literal: true

module Api
  module V1
    class FeedbacksController < Api::V1::ApplicationController
      before_action :set_stage
      before_action :set_feedback, only: %i[update destroy]

      def index
        feedbacks = policy_scope(Feedback).where(interview_stage: @stage)
        render json: feedbacks
      end

      def create
        feedback = @stage.feedbacks.new(feedback_params)
        authorize feedback

        if feedback.save
          render json: feedback, status: :created
        else
          render json: { errors: feedback.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        if @feedback.update(feedback_params)
          render json: @feedback
        else
          render json: { errors: @feedback.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        @feedback.destroy
        head :no_content
      end

      private

      def set_stage
        @stage = InterviewStage.joins(:position)
                               .where(positions: { user: current_user, id: params[:position_id] })
                               .find(params[:interview_stage_id])
      end

      def set_feedback
        @feedback = @stage.feedbacks.find(params[:id])
        authorize @feedback
      end

      def feedback_params
        params.expect(feedback: %i[feedback_type content])
      end
    end
  end
end
