resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.lambda_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.lambda_role.arn}"
      },
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.lambda_bucket.id}/*"
    }
  ]
}
POLICY
}

output "bucket_name" {
  value = aws_s3_bucket.lambda_bucket.id
}