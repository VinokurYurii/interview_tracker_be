# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < Api::V1::ApplicationController
      def index
        notifications = policy_scope(Notification).recent
        render json: notifications
      end

      def mark_read
        notification = Notification.find(params[:id])
        authorize notification
        notification.update!(read_at: DateTime.now)
        render json: notification
      end
    end
  end
end
