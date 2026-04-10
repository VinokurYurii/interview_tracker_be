# frozen_string_literal: true

class AutoCompletePastStagesJob < ApplicationJob
  queue_as :default

  def perform
    cutoff_at = 1.day.ago.beginning_of_day

    InterviewStage
      .where(status: 'planned')
      .where.not(scheduled_at: nil)
      .where('scheduled_at < ?', cutoff_at)
      .find_each do |stage|
      notification = Services::InterviewStages::AutoComplete.new(
        stage: stage,
        cutoff_at: cutoff_at
      ).call

      if notification
        Rails.logger.info(
          "[AutoCompletePastStagesJob] completed stage=#{stage.id} position=#{stage.position_id}"
        )
      end
    end
  end
end
