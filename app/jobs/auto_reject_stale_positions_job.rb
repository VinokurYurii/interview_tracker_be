# frozen_string_literal: true

class AutoRejectStalePositionsJob < ApplicationJob
  INACTIVE_DAYS = 30

  queue_as :default

  def perform
    threshold = INACTIVE_DAYS.days.ago

    Position.where(status: 'active').where('updated_at < ?', threshold).find_each do |position|
      notification = Services::Positions::AutoReject.new(
        position: position,
        inactive_days: INACTIVE_DAYS
      ).call

      if notification
        Rails.logger.info(
          "[AutoRejectStalePositionsJob] rejected position=#{position.id} user=#{position.user_id}"
        )
      end
    end
  end
end
