# frozen_string_literal: true

class SpinnerHandler
  def initialize
    @pastel = Pastel.new
  end

  def run
    spinner = TTY::Spinner.new("[:spinner] #{consulting_text}", format: :dots, clear: true)
    spinner.auto_spin
    yield
    spinner.success
  end

  private

  def consulting_text
    @pastel.green('Consulting with robots...')
  end
end
