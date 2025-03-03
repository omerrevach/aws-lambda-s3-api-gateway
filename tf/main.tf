resource "aws_iam_role" "lambda_role" {
name   = "Spacelift_Test_Lambda_Function_Role"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "get and put for s3"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.lambda_bucket.id}/*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/lambda_function.zip"
}


resource "aws_lambda_function" "terraform_lambda_func" {
  filename      = "${path.module}/lambda/lambda_function.zip"
  function_name = "write_and_retrieve_from_and_to_s3"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}



resource "aws_api_gateway_rest_api" "lambda_api" {
  name = "api_gateway_to_lambada"
}

// Create write resource
resource "aws_api_gateway_resource" "write_resource" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id // Links the resource to the main api gateway
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id // Defines where the resource is placed in tthe api structure
  path_part   = "write" // Specifies the URL path (/write or /readd)
}

// Create read resource
resource "aws_api_gateway_resource" "read_resource" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  path_part   = "read"
}

resource "aws_api_gateway_method" "write_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_resource.write_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "read_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_resource.read_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "write_integration" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_method.write_resource.id
  http_method = aws_api_gateway_method.write_method
  integration_http_method = "POST"
  type = "AWS_PROXY"

  uri = aws_lambda_function.terraform_lambda_func.invoke_url
}

resource "aws_api_gateway_integration" "read_integration" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.read_resource.id
  http_method = aws_api_gateway_method.read_method
  integration_http_method = "POST"
  type = "AWS_PROXY"

  uri = aws_lambda_function.terraform_lambda_func.invoke_url
}