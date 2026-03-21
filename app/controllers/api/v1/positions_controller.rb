# frozen_string_literal: true

module Api
  module V1
    class PositionsController < Api::V1::ApplicationController
      before_action :set_position, only: %i[show update destroy]

      def index
        positions = policy_scope(Position)
        render json: positions
      end

      def show
        render json: @position
      end

      def create
        position = current_user.positions.new(position_params)
        authorize position

        if position.save
          render json: position, status: :created
        else
          render json: { errors: position.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @position.update(update_params)
          render json: @position
        else
          render json: { errors: @position.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @position.destroy
        head :no_content
      end

      private

      def set_position
        @position = Position.find(params[:id])
        authorize @position
      end

      def position_params
        params.expect(position: %i[title description vacancy_url status company_id])
      end

      def update_params
        params.expect(position: %i[title description vacancy_url status])
      end
    end
  end
end
