# frozen_string_literal: true

class ResponseHandler
  def initialize
    @pastel = Pastel.new
  end

  def get_output_message(response)
    response.dig('choices', 0, 'message', 'content')
  end

  def save_audio_to_file(audio_data)
    File.open('tmp/response.mp3', 'wb') do |file|
      file.write(audio_data)
    end
  end

  def play_audio_response
    system('afplay tmp/response.mp3 &')
  end

  def print_response(response, output_message)
    puts @pastel.red('Bot: ') + @pastel.green(output_message)
    puts @pastel.yellow(usage_info(response))
  end

  private

  def usage_info(response_data)
    usage = response_data['usage']
    prompt_tokens = usage['prompt_tokens']
    completion_tokens = usage['completion_tokens']
    total_tokens = usage['total_tokens']
    "Prompt Tokens: #{prompt_tokens}, Completion Tokens: #{completion_tokens}, Total Tokens: #{total_tokens}"
  end
end
