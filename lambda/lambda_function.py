import json
import boto3
import os

# https://lepczynski.it/en/aws_en/how-to-read-and-write-a-file-on-s3-using-lambda-function-and-boto3/
# https://stackoverflow.com/questions/51217331/return-payload-for-a-api-gateway-aws

s3 = boto3.client("s3")
bucket_name = os.environ["BUCKET_NAME"]
file_name = "data.json"

def lambda_handler(event, context):
    
    print(event)
    http_method = event["httpMethod"]
    
    if http_method == "POST":
        try:
            body = json.loads(event['body'])
            s3.put_object(
                Key=file_name,
                Bucket=bucket_name,
                Body=json.dumps(body)
            )
            return {
                "statusCode": 200,
                "body": json.dumps({"message": "Data written to S3"}) # API Gateway requires statusCode and body
            }
        except (json.JSONDecodeError, KeyError):
            return {"statusCode": 400, "body": json.dumps({"error": "Invalid JSON"})}
        
    elif http_method == "GET":
        try:
            content = s3.get_object (
                Bucket=bucket_name,
                Key=file_name
            )["Body"].read().decode("utf-8")
            
            return {
                "statusCode": 200,
                "body": content
            }
        except s3.exceptions.NoSuchKey:
            return {"statusCode": 404, "body": json.dumps({"error": "File not found"})}
        
    return {"statusCode": 400, "body": json.dumps({"error": "Bad Request"})}
