class ChatManagerService
  def call
    ActiveRecord::Base.logger.silence do
      loop do
        display_chats
        input = user_input
        break if input == 'q'

        handle_input(input)
      end
    end
  end

  private

  def display_chats
    puts "\nAvailable chats:"
    Chat.all.order(created_at: :desc).each_with_index do |chat, index|
      puts "#{index + 1}. #{chat.title}"
    end
    display_options
  end

  def available_chats
    Chat.all.order(created_at: :desc)
  end

  def display_options
    puts "\nOptions:"
    puts 'Enter the chat number to start the conversation.'
    puts "Enter 'n' to create a new chat."
    puts "Enter 'd' followed by the chat number to delete a chat."
    puts "Enter 'q' to quit."
  end

  def user_input
    print "\nYour choice: "
    gets.chomp
  end

  def handle_input(input)
    case input
    when 'n'
      create_chat
    when /^d(\d+)$/
      delete_chat(input.match(/(\d+)$/)[0].to_i)
    when /^\d+$/
      chat_index = input.to_i
      handle_chat_selection(chat_index)
    else
      puts 'Invalid option.'
    end
  end

  def create_chat
    chat = Chat.new(title: chat_title)
    ChatService.new.chat_loop(chat)
  end

  def chat_title
    puts 'Enter the chat title:'
    gets.chomp
  end

  def delete_chat(chat_index)
    chat = available_chats[chat_index - 1]
    if chat
      chat.destroy
      puts "Chat '#{chat.title}' deleted."
    else
      puts 'Invalid chat number.'
    end
  end

  def handle_chat_selection(chat_index)
    chat = available_chats[chat_index - 1]
    if chat
      ChatService.new.chat_loop(chat)
    else
      puts 'Invalid chat number.'
    end
  end
end
