# frozen_string_literal: true

module Api
  module Auth
    class RegistrationsController < Devise::RegistrationsController
      skip_forgery_protection
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: resource, serializer: UserSerializer, status: :created
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def sign_up_params
        params.expect(user: %i[email password password_confirmation first_name last_name])
      end
    end
  end
end
