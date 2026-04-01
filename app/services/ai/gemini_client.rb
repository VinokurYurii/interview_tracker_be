# frozen_string_literal: true

module Services
  module AI
    class GeminiClient
      DEFAULT_MODEL = 'gemini-2.5-flash'
      GEMINI_URI_BASE = 'https://generativelanguage.googleapis.com/v1beta/'

      class Error < StandardError; end
      class ConnectionError < Error; end
      class ApiError < Error; end
      class RateLimitError < ApiError; end

      def initialize(model: DEFAULT_MODEL)
        @model = model
      end

      def call(prompt:, system: nil, temperature: 0.7, max_tokens: nil)
        messages = build_messages(prompt, system)
        parameters = build_parameters(messages, temperature, max_tokens)

        response = client.chat(parameters: parameters)
        parse_response(response)
      rescue Faraday::TooManyRequestsError => e
        raise RateLimitError, e.message
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
        raise ConnectionError, e.message
      rescue Faraday::ClientError, Faraday::ServerError => e
        raise ApiError, e.message
      rescue Faraday::Error => e
        raise ConnectionError, e.message
      end

      def self.call(...)
        new.call(...)
      end

      private

      def client
        @client ||= OpenAI::Client.new(
          access_token: api_key,
          uri_base: GEMINI_URI_BASE
        )
      end

      def api_key
        Rails.application.credentials.dig(:gemini, :api_key) ||
          raise(Error, 'Gemini API key not found in credentials')
      end

      def build_messages(prompt, system)
        messages = []
        messages << { role: 'system', content: system } if system
        messages << { role: 'user', content: prompt }
        messages
      end

      def build_parameters(messages, temperature, max_tokens)
        parameters = {
          model: @model,
          messages: messages,
          temperature: temperature
        }
        parameters[:max_tokens] = max_tokens if max_tokens
        parameters
      end

      def parse_response(response)
        error = response.dig('error')
        raise_api_error(error) if error

        {
          content: response.dig('choices', 0, 'message', 'content'),
          tokens_used: response.dig('usage', 'total_tokens'),
          model: @model
        }
      end

      def raise_api_error(error)
        message = error['message'] || 'Unknown API error'
        status = error['code']

        raise RateLimitError, message if status == 429
        raise ApiError, "#{status}: #{message}"
      end
    end
  end
end
