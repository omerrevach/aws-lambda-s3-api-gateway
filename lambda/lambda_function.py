import json
import boto3
import os

s3 = boto3.client("s3")
# Get the bucket name from environment variables in terraform
bucket_name = os.environ["BUCKET_NAME"]

def lambda_handler(event, context):
    """
    Main handler for Lambda function.
    Handles both POST requests (writing to S3) and GET requests (reading from S3).
    
    POST: Writes JSON body to S3 with file_name from query parameter
    GET: Retrieves file content from S3 based on file_name query parameter
    """
    print(event)
    http_method = event["httpMethod"]
    
    # Handle POST request (write to s3)
    if http_method == "POST":
        try:
            body = json.loads(event.get('body', '{}'))
            # Get filename from query parameter or use default
            file_name = event.get("queryStringParameters", {}).get("file_name", "default.json")
            
            # Write json data to s3
            s3.put_object(
                Key=file_name,
                Bucket=bucket_name,
                Body=json.dumps(body)
            )
            return {
                "statusCode": 200,
                "body": json.dumps({"message": f"Data written to {file_name}"}) # API Gateway requires statusCode and body
            }
        except (json.JSONDecodeError, KeyError):
            return {"statusCode": 400, "body": json.dumps({"error": "Invalid JSON"})}
        
    # Handle GET request (read from S3)
    elif http_method == "GET":
        # Retrieve the file from s3
        file_name = event.get("queryStringParameters", {}).get("file_name", "data.json")
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
