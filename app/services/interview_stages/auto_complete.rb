# frozen_string_literal: true

module Services
  module InterviewStages
    class AutoComplete
      attr_reader :stage, :cutoff_at

      def initialize(stage:, cutoff_at:)
        @stage = stage
        @cutoff_at = cutoff_at
      end

      def call
        ActiveRecord::Base.transaction do
          stage.lock!
          return nil unless eligible?

          # NOTE: update_columns is intentional here. A normal `update!` would
          # trigger `touch: true` on the parent Position, bumping its
          # `updated_at` and effectively restarting the 30-day inactivity clock
          # used by AutoRejectStalePositionsJob. By writing the column directly
          # we keep the position's activity timestamp untouched while still
          # advancing the stage's own `updated_at` for audit/sorting.
          stage.update_columns(status: 'done', updated_at: Time.current)
          create_notification
        end
      end

      private

      def eligible?
        stage.planned? && stage.scheduled_at.present? && stage.scheduled_at < cutoff_at
      end

      def create_notification
        Notification.create!(
          user: stage.position.user,
          notifiable: stage,
          title: 'Interview stage marked as completed',
          body: notification_body
        )
      end

      def notification_body
        position = stage.position
        company = position.company
        "Your #{stage.stage_type.humanize} stage for #{position.title} at #{company.name}, " \
          "scheduled on #{stage.scheduled_at.to_date}, was automatically marked as done. " \
          "If that's not the case, you can update it."
      end
    end
  end
end
