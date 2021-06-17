awslocal sqs create-queue --cli-input-json file:///docker-entrypoint-initaws.d/json/dead-letter.json
awslocal sqs create-queue --cli-input-json file:///docker-entrypoint-initaws.d/json/sqs-queue.json
