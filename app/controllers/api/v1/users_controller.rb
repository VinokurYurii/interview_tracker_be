# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::ApplicationController
      before_action { authorize current_user }

      def show
        render json: current_user
      end

      def update
        if current_user.update(user_params)
          render json: current_user
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def user_params
        params.expect(user: %i[first_name last_name])
      end
    end
  end
end
