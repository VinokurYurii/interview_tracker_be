# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::ApplicationController
      before_action { authorize current_user }

      def show
        render json: { data: serialize(current_user) }
      end

      def update
        if current_user.update(user_params)
          render json: { data: serialize(current_user) }
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.expect(user: %i[first_name last_name])
      end

      def serialize(user)
        { id: user.id, first_name: user.first_name, last_name: user.last_name, email: user.email }
      end
    end
  end
end
