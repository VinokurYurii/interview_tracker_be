# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def user_not_authorized
    render json: { errors: ['Not authorized'] }, status: :forbidden
  end

  def record_not_found
    render json: { errors: ['Record not found'] }, status: :not_found
  end
end
