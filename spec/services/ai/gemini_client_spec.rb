# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::AI::GeminiClient do
  let(:api_key) { 'test-api-key' }
  let(:client) { described_class.new }
  let(:openai_client) { instance_double(OpenAI::Client) }

  before do
    allow(Rails.application.credentials).to receive(:dig).with(:gemini, :api_key).and_return(api_key)
    allow(OpenAI::Client).to receive(:new).and_return(openai_client)
  end

  describe '#initialize' do
    it 'does not create OpenAI client eagerly' do
      described_class.new
      expect(OpenAI::Client).not_to have_received(:new)
    end
  end

  describe '#call' do
    let(:gemini_response) do
      {
        'choices' => [
          { 'finish_reason' => 'stop', 'index' => 0, 'message' => { 'content' => 'AI response text', 'role' => 'assistant' } }
        ],
        'usage' => { 'completion_tokens' => 10, 'prompt_tokens' => 5, 'total_tokens' => 42 }
      }
    end

    before do
      allow(openai_client).to receive(:chat).and_return(gemini_response)
    end

    it 'returns parsed response with content, tokens, and model' do
      result = client.call(prompt: 'Hello')

      expect(result).to eq(
        content: 'AI response text',
        tokens_used: 42,
        model: 'gemini-2.5-flash'
      )
    end

    it 'sends system message when provided' do
      client.call(prompt: 'Hello', system: 'You are a helper')

      expect(openai_client).to have_received(:chat).with(
        parameters: hash_including(
          messages: [
            { role: 'system', content: 'You are a helper' },
            { role: 'user', content: 'Hello' }
          ]
        )
      )
    end

    it 'omits system message when not provided' do
      client.call(prompt: 'Hello')

      expect(openai_client).to have_received(:chat).with(
        parameters: hash_including(
          messages: [{ role: 'user', content: 'Hello' }]
        )
      )
    end

    it 'passes temperature and max_tokens' do
      client.call(prompt: 'Hello', temperature: 0.2, max_tokens: 500)

      expect(openai_client).to have_received(:chat).with(
        parameters: hash_including(temperature: 0.2, max_tokens: 500)
      )
    end

    it 'omits max_tokens when nil' do
      client.call(prompt: 'Hello')

      expect(openai_client).to have_received(:chat) do |args|
        expect(args[:parameters]).not_to have_key(:max_tokens)
      end
    end

    context 'with custom model' do
      let(:client) { described_class.new(model: 'gemini-2.5-pro') }

      it 'uses the specified model' do
        result = client.call(prompt: 'Hello')

        expect(result[:model]).to eq('gemini-2.5-pro')
      end
    end
  end

  describe '.call' do
    let(:gemini_response) do
      {
        'choices' => [
          { 'message' => { 'content' => 'Response' } }
        ],
        'usage' => { 'total_tokens' => 10 }
      }
    end

    it 'creates instance with defaults and delegates to #call' do
      allow(openai_client).to receive(:chat).and_return(gemini_response)

      result = described_class.call(prompt: 'Hello')

      expect(result[:content]).to eq('Response')
    end
  end

  describe 'error handling' do
    it 'raises RateLimitError on 429' do
      allow(openai_client).to receive(:chat).and_raise(Faraday::TooManyRequestsError.new('Rate limit exceeded'))

      expect { client.call(prompt: 'Hello') }.to raise_error(described_class::RateLimitError, /Rate limit exceeded/)
    end

    it 'raises ApiError on client errors' do
      allow(openai_client).to receive(:chat).and_raise(Faraday::ClientError.new('Bad request'))

      expect { client.call(prompt: 'Hello') }.to raise_error(described_class::ApiError, /Bad request/)
    end

    it 'raises ApiError on server errors' do
      allow(openai_client).to receive(:chat).and_raise(Faraday::ServerError.new('Internal server error'))

      expect { client.call(prompt: 'Hello') }.to raise_error(described_class::ApiError, /Internal server error/)
    end

    it 'raises ApiError on error in response body' do
      allow(openai_client).to receive(:chat).and_return(
        'error' => { 'code' => 400, 'message' => 'Invalid prompt' }
      )

      expect { client.call(prompt: 'Hello') }.to raise_error(described_class::ApiError, '400: Invalid prompt')
    end

    it 'raises ConnectionError on network failures' do
      allow(openai_client).to receive(:chat).and_raise(Faraday::ConnectionFailed.new('Connection refused'))

      expect { client.call(prompt: 'Hello') }.to raise_error(described_class::ConnectionError, /Connection refused/)
    end

    it 'raises ConnectionError on timeout' do
      allow(openai_client).to receive(:chat).and_raise(Faraday::TimeoutError.new('Timeout'))

      expect { client.call(prompt: 'Hello') }.to raise_error(described_class::ConnectionError, /Timeout/)
    end

    it 'raises Error when API key is missing' do
      allow(Rails.application.credentials).to receive(:dig).with(:gemini, :api_key).and_return(nil)

      expect { described_class.new.call(prompt: 'Hello') }.to raise_error(described_class::Error, /API key not found/)
    end
  end
end
