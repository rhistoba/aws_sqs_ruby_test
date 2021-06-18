require 'aws-sdk-sqs'
require 'json'

REGION = 'ap-northeast-1'
LOCALSTACK_ACCESS_KEY = 'access-key'
LOCALSTACK_SECRET_KEY = 'access-secret'
LOCALSTACK_ENDPOINT = 'http://localhost:4566'
SQS_QUEUE_URL = 'http://localhost:4566/queue/sqs-queue'
SQS_QUEUE_NAME = 'sqs-queue'
SQS_WAIT_TIME_SECONDS = 5
TARGET_EVENT_SOURCE = 'aws:s3'
TARGET_EVENT_NAME = 'ObjectCreated:Put'

def run
  sqs = Aws::SQS::Client.new(
    region: REGION, 
    access_key_id: LOCALSTACK_ACCESS_KEY, 
    secret_access_key: LOCALSTACK_SECRET_KEY,
    endpoint: LOCALSTACK_ENDPOINT
  )

  p 'Start receiving sqs messages...'

  while 1 do
    receive_message_result = sqs.receive_message({
      queue_url: SQS_QUEUE_URL, 
      message_attribute_names: ["All"],
      max_number_of_messages: 1,
      wait_time_seconds: SQS_WAIT_TIME_SECONDS 
    })

    now = Time.now
    p "Confirmed at #{now.to_s}"

    messages = receive_message_result.messages
    if messages.empty?
      p 'No messages found.'
    else
      p "#{messages.count} messages found."

      messages.each do |message|
        body_hash = JSON.parse(message.body)
        record = body_hash['Records'][0]

        eventSource = record.dig('eventSource')
        eventName = record.dig('eventName')

        if eventSource == TARGET_EVENT_SOURCE && eventName == TARGET_EVENT_NAME
          key = record.dig('s3', 'object', 'key') 
          p "File uploaded. key: #{key}"
        else
          p "Not correct eventSource (#{eventSource}) or eventName (#{eventName})."
          p 'This message will be skipped and deleted.'
        end

        sqs.delete_message({
          queue_url: SQS_QUEUE_URL,
          receipt_handle: message.receipt_handle
        })
      end
    end
  end
end

run if $PROGRAM_NAME == __FILE__
