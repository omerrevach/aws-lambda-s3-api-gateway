output "api_gateway_url" {
  description = "Base URL for API Gateway"
  value       = "https://${aws_api_gateway_rest_api.lambda_api.id}.execute-api.${var.region}.amazonaws.com/prod"
}
