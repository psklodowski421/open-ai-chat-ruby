# frozen_string_literal: true

module Integrations
  class OpenaiService
    def initialize(messages)
      @openai = OpenAI::Client.new
      @messages = messages
    end

    def chat
      @openai.chat(
        parameters: {
          model: ENV['OPENAI_MODEL'],
          messages: @messages,
          max_tokens: 1024
        }
      )
    end
  end
end
