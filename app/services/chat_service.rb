class ChatService
  def initialize
    @pastel = Pastel.new
    @input_handler = InputHandler.new
    @spinner_handler = SpinnerHandler.new
    @response_handler = ResponseHandler.new
  end

  def chat_loop(chat)
    @messages = get_messages(chat)

    loop do
      input = @input_handler.get_input

      add_message(chat, 'user', input)

      response = nil
      output_message = nil

      @spinner_handler.run do
        response = OpenaiService.new(@messages).chat
        output_message = @response_handler.get_output_message(response)

        add_message(chat, 'assistant', output_message)

        audio_data = PollyService.new(output_message).synthesize_speech
        @response_handler.save_audio_to_file(audio_data)
      end
      @response_handler.play_audio_response
      @response_handler.print_response(response, output_message)
    end
  ensure
    system('killall afplay')
  end

  private

  def get_messages(chat)
    chat.messages.order(:created_at).map { |message| { role: message.role, content: message.content } }
  end

  def add_message(chat, role, content)
    ActiveRecord::Base.logger.silence do
      Message.create(chat: chat, role: role, content: content)
      @messages << { role: role, content: content }
    end
  end
end
