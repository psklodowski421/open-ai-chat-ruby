# frozen_string_literal: true

class InputHandler
  def get_input
    input_lines = []
    print 'You: '
    while (line = gets.chomp) != '##'
      input_lines << line
    end
    input_lines.join('')
  end
end
