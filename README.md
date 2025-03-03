aws logs tail /aws/lambda/write_and_retrieve_from_and_to_s3 --follow

curl -X POST "api-gateway-url/prod/write" \
     -H "Content-Type: application/json" \
     -d '{"message": "Hello from Lambda"}'

curl -X GET "api-gateway-url/prod/read"


terraform output api_gateway_url
