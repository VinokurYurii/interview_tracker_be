# frozen_string_literal: true

class GenerateResumeAnalysisJob < ApplicationJob
  queue_as :ai

  def perform(user_id:, resume_id:)
    analysis = ResumeAnalysis.find_by!(resume_id: resume_id)
    analysis.update!(status: :processing)

    result = Services::AI::GenerateCareerInsights.new(user_id: user_id, resume_id: resume_id).call

    analysis.update!(
      status: :completed,
      content: result[:content],
      tokens_used: result[:tokens_used],
      model: result[:model]
    )
  rescue StandardError => e
    analysis&.update!(status: :failed, error_message: e.message)
    raise
  end
end
