# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ::ApplicationController
      skip_forgery_protection
      before_action :authenticate_user!
    end
  end
end
