# frozen_string_literal: true

module Services
  module Resumes
    class RequestAnalysis
      attr_reader :resume

      def initialize(resume)
        @resume = resume
      end

      def call
        return not_analyzable_error unless resume.analyzable?
        return in_progress_error if analysis_in_progress?

        analysis = resume.resume_analysis || resume.build_resume_analysis
        analysis.update!(
          status: :pending,
          content: nil,
          tokens_used: nil,
          model: nil,
          error_message: nil
        )

        GenerateResumeAnalysisJob.perform_later(user_id: resume.user_id, resume_id: resume.id)

        { success: true, analysis: analysis }
      end

      private

      def analysis_in_progress?
        resume.resume_analysis&.pending? || resume.resume_analysis&.processing?
      end

      def not_analyzable_error
        errors = []
        errors << 'Resume has no attached file' unless resume.file.attached?
        errors << 'Resume has no positions with interview stages' unless resume.positions.joins(:interview_stages).exists?

        { success: false, error: errors.join('. ') }
      end

      def in_progress_error
        { success: false, error: 'Analysis is already in progress' }
      end
    end
  end
end
