class ChatService

  def test
    ChatService.new.chat_manager
  end

  def initialize
    @pastel = Pastel.new
  end

  def chat_manager
    ActiveRecord::Base.logger.silence do
      loop do
        puts "\nAvailable chats:"
        chats = Chat.all

        chats.each_with_index do |chat, index|
          puts "#{index + 1}. #{chat.title}"
        end

        puts "\nOptions:"
        puts 'Enter the chat number to start the conversation.'
        puts "Enter 'n' to create a new chat."
        puts "Enter 'd' followed by the chat number to delete a chat."
        puts "Enter 'q' to quit."

        print "\nYour choice: "
        input = gets.chomp

        case input
        when 'q'
          break
        when 'n'
          puts 'Enter the chat title: '
          chat_title = gets.chomp
          chat_loop(Chat.new(title: chat_title))
        when /^d(\d+)$/
          chat_id = $1.to_i
          chat = chats[chat_id - 1]
          if chat
            chat.destroy
            puts "Chat '#{chat.title}' deleted."
          else
            puts 'Invalid chat number.'
          end
        when /^\d+$/
          chat_id = input.to_i
          chat = chats[chat_id - 1]
          if chat
            chat_loop(chat)
          else
            puts 'Invalid chat number.'
          end
        else
          puts 'Invalid option.'
        end
      end
    end
  end

  def chat_loop(chat)
    chat ||= Chat.find_or_create_by(title: chat.title)
    @messages = find_messages(chat)
    begin
      loop do
        input = input_from_user

        add_message(chat, 'user', input)

        response = nil
        output_message = nil

        spinner.run do
          response = OpenaiService.new(@messages).chat

          output_message = response.dig('choices', 0, 'message', 'content')

          add_message(chat, 'assistant', output_message)

          audio_data = PollyService.new(output_message).synthesize_speech

          save_to_file(audio_data)
        end

        play_response
        print_response(response, output_message)
      end
    ensure
      # Stop all afplay processes when exiting the loop
      system('killall afplay')
    end
  end

  def input_from_user
    input_lines = []
    print 'You: '
    while (line = gets.chomp) != '##'
      input_lines << line
    end
    input_lines.join('')
  end

  def add_message(chat, role, input)
    ActiveRecord::Base.logger.silence do
      Message.create(chat: chat, role: role, content: input)
      @messages << { role: 'user', content: input }
    end
  end

  def find_messages(chat)
    chat.messages.order(:created_at).map { |message| { role: message.role, content: message.content } }
  end

  def print_response(response, output_message)
    puts @pastel.red('Bot: ') + @pastel.green(output_message)
    puts @pastel.yellow(usage_info(response))
  end

  def play_response
    system('afplay tmp/response.mp3 &')
  end

  def save_to_file(audio_data)
    File.open('tmp/response.mp3', 'wb') do |file|
      file.write(audio_data)
    end
  end

  def spinner
    pastel = Pastel.new
    green_text = pastel.green('Consulting with robots...')
    TTY::Spinner.new("[:spinner] #{green_text}", format: :dots, clear: true)
  end

  def usage_info(response_data)
    usage = response_data['usage']
    prompt_tokens = usage['prompt_tokens']
    completion_tokens = usage['completion_tokens']
    total_tokens = usage['total_tokens']
    "Prompt Tokens: #{prompt_tokens}, Completion Tokens: #{completion_tokens}, Total Tokens: #{total_tokens}"
  end
end
