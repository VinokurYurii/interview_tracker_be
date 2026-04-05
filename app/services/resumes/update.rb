# frozen_string_literal: true

module Services
  module Resumes
    class Update
      attr_reader :resume, :params

      def initialize(resume, params)
        @resume = resume
        @params = params
      end

      def call
        resume.assign_attributes(params)

        ActiveRecord::Base.transaction do
          clear_default_resumes if resume.default_changed? && resume.default?
          resume.save!
        end

        { success: true, resume: resume }
      rescue ActiveRecord::RecordInvalid
        { success: false, errors: resume.errors.full_messages }
      end

      private

      def clear_default_resumes
        resume.user.resumes.where(default: true).update_all(default: false)
      end
    end
  end
end
