# frozen_string_literal: true

module Services
  module Resumes
    class Create
      attr_reader :user, :params

      def initialize(user, params)
        @user = user
        @params = params
      end

      def call
        resume = user.resumes.new(params)
        resume.default = true unless user_has_default?

        ActiveRecord::Base.transaction do
          clear_default_resumes if resume.default?
          resume.save!
        end

        { success: true, resume: resume }
      rescue ActiveRecord::RecordInvalid
        { success: false, errors: resume.errors.full_messages }
      end

      private

      def user_has_default?
        user.resumes.exists?(default: true)
      end

      def clear_default_resumes
        user.resumes.where(default: true).update_all(default: false)
      end
    end
  end
end
