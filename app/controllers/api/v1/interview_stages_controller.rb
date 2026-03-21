# frozen_string_literal: true

module Api
  module V1
    class InterviewStagesController < Api::V1::ApplicationController
      before_action :set_position
      before_action :set_stage, only: %i[show update destroy]

      def index
        stages = policy_scope(InterviewStage).where(position: @position)
        render json: stages
      end

      def show
        render json: @stage
      end

      def create
        stage = @position.interview_stages.new(stage_params)
        authorize stage

        if stage.save
          render json: stage, status: :created
        else
          render json: { errors: stage.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @stage.update(update_params)
          render json: @stage
        else
          render json: { errors: @stage.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @stage.destroy
        head :no_content
      end

      private

      def set_position
        @position = Position.find(params[:position_id])
      end

      def set_stage
        @stage = @position.interview_stages.find(params[:id])
        authorize @stage
      end

      def stage_params
        params.expect(interview_stage: %i[stage_type status scheduled_at calendar_link notes])
      end

      def update_params
        params.expect(interview_stage: %i[stage_type status scheduled_at calendar_link notes])
      end
    end
  end
end
