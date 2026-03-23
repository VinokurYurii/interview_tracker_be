# frozen_string_literal: true

module Api
  module Auth
    class SessionsController < Devise::SessionsController
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        render json: resource, serializer: UserSerializer, status: :ok
      end

      def respond_to_on_destroy(**)
        if current_user
          render json: { message: 'Signed out' }, status: :ok
        else
          render json: { errors: ['No active session'] }, status: :unauthorized
        end
      end
    end
  end
end
