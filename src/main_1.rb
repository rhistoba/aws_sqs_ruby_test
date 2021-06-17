require 'aws-sdk-sqs'

REGION = 'ap-northeast-1'
LOCALSTACK_ACCESS_KEY = 'access-key'
LOCALSTACK_SECRET_KEY = 'access-secret'
LOCALSTACK_ENDPOINT = 'http://localhost:4566'
SQS_QUEUE_URL = 'http://localhost:4566/queue/sqs-queue'

def list_queue_urls(sqs_client)
  queues = sqs_client.list_queues

  queues.queue_urls.each do |url|
    puts url
  end
rescue StandardError => e
  puts "Error listing queue URLs: #{e.message}"
end

def list_queue_attributes(sqs_client, queue_url)
  attributes = sqs_client.get_queue_attributes(
    queue_url: queue_url,
    attribute_names: [ "All" ]
  )

  attributes.attributes.each do |key, value|
    puts "#{key}: #{value}"
  end

rescue StandardError => e
  puts "Error getting queue attributes: #{e.message}"
end

def run
  sqs_client = Aws::SQS::Client.new(
    region: REGION, 
    access_key_id: LOCALSTACK_ACCESS_KEY, 
    secret_access_key: LOCALSTACK_SECRET_KEY,
    endpoint: LOCALSTACK_ENDPOINT
  )

  puts 'SQSキューのURL一覧を取得'
  list_queue_urls(sqs_client)

  puts "SQSキュー#{SQS_QUEUE_URL}の情報を取得"
  list_queue_attributes(sqs_client, SQS_QUEUE_URL)
end

run if $PROGRAM_NAME == __FILE__
