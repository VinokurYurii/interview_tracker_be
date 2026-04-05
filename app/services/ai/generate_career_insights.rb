# frozen_string_literal: true

module Services
  module AI
    class GenerateCareerInsights
      SYSTEM_PROMPT = <<~PROMPT
        You are an experienced career consultant. Analyze the candidate's resume and their \
        interview history across multiple positions. Identify patterns in their interview \
        performance, highlight strengths and weaknesses, and provide actionable recommendations \
        for improving their interview success rate. Structure your response with clear sections: \
        Strengths, Weaknesses, Patterns, and Recommendations.
      PROMPT

      attr_reader :user_id, :resume_id

      def initialize(user_id:, resume_id:)
        @user_id = user_id
        @resume_id = resume_id
      end

      def call
        Services::AI::GeminiClient.call(
          prompt: prompt,
          system: SYSTEM_PROMPT
        )
      end

      private

      def payload
        @payload ||= Services::AI::BuildCareerPayload.new(user_id: user_id, resume_id: resume_id).call
      end

      def prompt
        "Here is the candidate's data:\n#{payload.to_json}"
      end
    end
  end
end
