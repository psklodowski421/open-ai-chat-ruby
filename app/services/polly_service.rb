class PollyService
  def initialize(text)
    @polly = Aws::Polly::Client.new
    @text = text
  end

  def synthesize_speech
    response = @polly.synthesize_speech(
      text: @text,
      voice_id: 'Ivy',
      output_format: 'mp3',
      language_code: 'en-US'
    )

    response.audio_stream.read
  end
end