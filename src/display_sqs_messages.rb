require 'aws-sdk-sqs'
require 'json'

REGION = 'ap-northeast-1'
LOCALSTACK_ACCESS_KEY = 'access-key'
LOCALSTACK_SECRET_KEY = 'access-secret'
LOCALSTACK_ENDPOINT = 'http://localhost:4566'
SQS_QUEUE_URL = 'http://localhost:4566/queue/sqs-queue'
SQS_QUEUE_NAME = 'sqs-queue'
SQS_WAIT_TIME_SECONDS = 5

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
      max_number_of_messages: 10,
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
        key = body_hash['Records'][0].dig('s3', 'object', 'key') 
        p "File uploaded. key: #{key}"

        sqs.delete_message({
          queue_url: SQS_QUEUE_URL,
          receipt_handle: message.receipt_handle
        })
      end
    end
  end
end

run if $PROGRAM_NAME == __FILE__
