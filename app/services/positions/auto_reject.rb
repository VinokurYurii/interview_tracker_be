# frozen_string_literal: true

module Services
  module Positions
    class AutoReject
      attr_reader :position, :inactive_days

      def initialize(position:, inactive_days:)
        @position = position
        @inactive_days = inactive_days
      end

      def call
        ActiveRecord::Base.transaction do
          position.lock!
          return nil unless eligible?

          position.update!(status: :rejected)
          create_notification
        end
      end

      private

      def eligible?
        position.active? && position.updated_at < inactive_days.days.ago
      end

      def create_notification
        Notification.create!(
          user: position.user,
          notifiable: position,
          title: 'Position marked as rejected due to inactivity',
          body: notification_body
        )
      end

      def notification_body
        "#{position.title} at #{position.company.name} had no activity for " \
          "#{inactive_days} days and was automatically marked as rejected. " \
          'You can reopen it by changing the status back to Active.'
      end
    end
  end
end
