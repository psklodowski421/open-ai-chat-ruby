# frozen_string_literal: true

require 'aws-sdk-polly'

Aws.config.update({
                    region: ENV['AWS_REGION'],
                    credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
                  })
