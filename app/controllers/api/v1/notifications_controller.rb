# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < Api::V1::ApplicationController
      def index
        notifications = policy_scope(Notification).includes(:notifiable).recent
        render json: notifications
      end

      def mark_read
        notification = policy_scope(Notification).find(params[:id])
        notification.update!(read_at: DateTime.now)
        render json: notification
      end
    end
  end
end
