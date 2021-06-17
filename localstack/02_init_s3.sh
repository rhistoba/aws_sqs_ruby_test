awslocal s3 mb s3://sqs-test-bucket

awslocal s3api put-bucket-notification-configuration --bucket sqs-test-bucket --notification-configuration file:///docker-entrypoint-initaws.d/json/notification.json
