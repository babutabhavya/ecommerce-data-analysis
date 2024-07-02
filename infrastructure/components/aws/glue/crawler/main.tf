# Define IAM policy for S3 bucket access
resource "aws_iam_policy" "glue_s3_access_policy" {
  name        = "GlueS3AccessPolicy${var.name}"
  description = "IAM policy for AWS Glue to access S3 bucket"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect : "Allow"
          Action : [
            "s3:GetObject",
            "s3:PutObject",
          ]
          Resource = "arn:aws:s3:::${var.s3_bucket_name}/${var.bucket_folder}/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "glue:*",
            "s3:GetBucketLocation",
            "s3:ListBucket",
            "s3:ListAllMyBuckets",
            "s3:GetBucketAcl",
            "ec2:DescribeVpcEndpoints",
            "ec2:DescribeRouteTables",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcAttribute",
            "iam:ListRolePolicies",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "cloudwatch:PutMetricData"
          ],
          "Resource" : [
            "*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:CreateBucket"
          ],
          "Resource" : [
            "arn:aws:s3:::aws-glue-*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ],
          "Resource" : [
            "arn:aws:s3:::aws-glue-*/*",
            "arn:aws:s3:::*/*aws-glue-*/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject"
          ],
          "Resource" : [
            "arn:aws:s3:::crawler-public*",
            "arn:aws:s3:::aws-glue-*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : [
            "arn:aws:logs:*:*:*:/aws-glue/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateTags",
            "ec2:DeleteTags"
          ],
          "Condition" : {
            "ForAllValues:StringEquals" : {
              "aws:TagKeys" : [
                "aws-glue-service-resource"
              ]
            }
          },
          "Resource" : [
            "arn:aws:ec2:*:*:network-interface/*",
            "arn:aws:ec2:*:*:security-group/*",
            "arn:aws:ec2:*:*:instance/*"
          ]
        }
      ]
  })
}


# Attach IAM policy to the Glue service role
resource "aws_iam_role_policy_attachment" "glue_s3_access_attachment" {
  role       = var.service_role_name
  policy_arn = aws_iam_policy.glue_s3_access_policy.arn
}

# Define Glue crawler to crawl the S3 bucket
resource "aws_glue_crawler" "order_status_crawler" {
  name          = "${var.name}-crawler"
  role          = var.service_role_name
  database_name = var.database_name

  s3_target {
    path = "s3://${var.s3_bucket_name}/${var.bucket_folder}"
  }
}
