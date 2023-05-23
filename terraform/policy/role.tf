resource "aws_iam_role" "sre_engineer_role" {
  name = "SRE_Engineer_Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "sre_engineer_policy" {
  name        = "SRE_Engineer_Policy"
  description = "Policy for SRE Engineer Role"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:Query",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "sns:Publish",
        "sns:Subscribe",
        "sns:Unsubscribe",
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "kinesis:PutRecord",
        "kinesis:GetRecords",
        "kinesis:GetShardIterator",
        "kinesis:DescribeStream"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sre_engineer_role_policy_attachment" {
  role       = aws_iam_role.sre_engineer_role.name
  policy_arn = aws_iam_policy.sre_engineer_policy.arn
}
