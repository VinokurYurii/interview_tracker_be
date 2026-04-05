# frozen_string_literal: true

module Services
  module AI
    class BuildCareerPayload
      attr_reader :user_id, :resume_id

      def initialize(user_id:, resume_id:)
        @user_id = user_id
        @resume_id = resume_id
      end

      def call
        {
          resume_title: resume.name,
          resume_text: resume_text,
          positions: build_positions
        }
      end

      private

      def resume
        @resume ||= Resume.find(resume_id)
      end

      def resume_text
        @resume_text ||= Services::Resumes::ExtractText.new(resume).call
      end

      def positions_with_stages
        @positions_with_stages ||= resume.positions
          .joins(:interview_stages)
          .includes(:company, interview_stages: :feedbacks)
          .distinct
      end

      def build_positions
        raise ArgumentError, 'No positions with interview stages found' if positions_with_stages.empty?

        positions_with_stages.map { |position| build_position(position) }
      end

      def build_position(position)
        {
          title: position.title,
          company_name: position.company.name,
          description: position.description,
          status: position.status,
          interview_stages: position.interview_stages.map { |stage| build_stage(stage) }
        }
      end

      def build_stage(stage)
        {
          stage_type: stage.stage_type,
          status: stage.status,
          scheduled_at: stage.scheduled_at&.iso8601,
          notes: stage.notes,
          self_feedback: feedback_content(stage, 'self_review'),
          company_feedback: feedback_content(stage, 'company')
        }.compact
      end

      def feedback_content(stage, type)
        stage.feedbacks.find { |f| f.feedback_type == type }&.content
      end
    end
  end
end
