# frozen_string_literal: true

module Integrations
  class TranscryptionService
    def real_time_transcript(audio_file_path)
      async_client = Aws::TranscribeStreamingService::AsyncClient.new

      input_stream = Aws::TranscribeStreamingService::EventStreams::AudioStream.new
      output_stream = Aws::TranscribeStreamingService::EventStreams::TranscriptResultStream.new

      audio_file = File.new(audio_file_path, 'rb')
      transcript_parts = []

      # Register callbacks
      output_stream.on_transcript_event_event do |event|
        unless event.transcript.results.empty?
          event.transcript.results.each do |result|
            result.alternatives.each do |alter|
              transcript_parts << alter.transcript
              puts alter.transcript
            end
          end
        end
      end
      output_stream.on_bad_request_exception_event do |_exception|
        input_stream.signal_end_stream
      end

      # Make an async call
      async_resp = async_client.start_stream_transcription(
        language_code: 'en-US',
        media_encoding: 'pcm',
        media_sample_rate_hertz: 48_000,
        input_event_stream_handler: input_stream,
        output_event_stream_handler: output_stream
      )
      # => Aws::Seahorse::Client::AsyncResponse

      # Signaling audio chunks
      input_stream.signal_audio_event_event(audio_chunk: audio_file.read(20_000)) until audio_file.eof?
      input_stream.signal_end_stream
      audio_file.close
      async_resp.wait
      transcript_parts.last
    end

    def transcribe_audio_file(audio_file_path)
      bucket_name = 'open-ai-communication'
      object_key = File.basename(audio_file_path)
      s3_uri = "s3://#{bucket_name}/#{object_key}"

      upload_file_to_s3(audio_file_path, bucket_name, object_key)

      client = Aws::TranscribeService::Client.new

      job_name = "transcription-job-#{Time.now.to_i}"
      media_format = 'mp3' # Change this based on your audio file format (mp3, mp4, wav, flac)

      client.start_transcription_job(
        transcription_job_name: job_name,
        language_code: 'en-US',
        media_format:,
        media: { media_file_uri: s3_uri }
      )

      transcription_status = 'IN_PROGRESS'
      while transcription_status == 'IN_PROGRESS'
        sleep 1
        transcription_status_response = client.get_transcription_job(transcription_job_name: job_name)
        transcription_status = transcription_status_response.transcription_job.transcription_job_status
        puts "Transcription status: #{transcription_status}"
      end

      if transcription_status == 'COMPLETED'
        transcription_uri = transcription_status_response.transcription_job.transcript.transcript_file_uri
        puts "Transcription JSON URI: #{transcription_uri}"

        json_data = Net::HTTP.get(URI(transcription_uri))
        transcript_data = JSON.parse(json_data)
        transcript = transcript_data['results']['transcripts'].first['transcript']
        puts "Transcription result: #{transcript}"
      else
        puts 'Error: Transcription job failed.'
      end
    end

    def upload_file_to_s3(audio_file_path, bucket_name, object_key)
      s3_client = Aws::S3::Client.new(region: ENV['AWS_REGION'])
      s3_client.put_object(
        body: File.open(audio_file_path, 'rb'),
        bucket: bucket_name,
        key: object_key
      )
    end
  end
end
