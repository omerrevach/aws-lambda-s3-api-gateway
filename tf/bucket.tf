resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "_lambda-bucket-wizard-wiz"
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
        "AWS": "${aws_iam_role.lambda_role.arn}" // only this role that is attached to lambbda is allowed access
      },
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.lambda.bucket.id}/*"
    }
  ]
}
POLICY
}

output "bucket_name" {
  value = aws_s3_bucket.lambda_bucket.id
}