resource "aws_iam_instance_profile" "ecs_host" {
  name = "cb-ecs_host-${var.client_name}-instance_profile"
  role = aws_iam_role.ecs_host.name
  tags = merge(
    { Name        = "cb-ecs_td-${var.client_name}-master" },
    local.common_tags
  )
}
resource "aws_iam_role" "ecs_host" {
  name = "cb-iam_role-${var.client_name}-ecs_host"
  path = "/"
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

  inline_policy {
    name = "cb-iam_policy-${var.client_name}-ecs_host"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "route53:ListResourceRecordSets",
                "ec2:DescribeTags",
                "ecs:CreateCluster",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:UpdateContainerInstancesState",
                "ecs:Submit*",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "cloudwatch:PutMetricData",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "ec2:AssociateAddress",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": "ec2:AttachVolume",
      "Resource": [
        "${aws_ebs_volume.media.arn}",
        "arn:aws:ec2:${var.region_name}:${data.aws_caller_identity.current.account_id}:instance/*"
      ],
      "Effect": "Allow"
    },
    {
      "Action": "ec2:DescribeVolume*",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
        "kms:CreateGrant"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
  }
  tags = merge(
    { Name        = "cb-iam_role-${var.client_name}-ecs_host" },
    local.common_tags
  )
}


resource "aws_iam_role" "ecs_task" {
  name = "cb-iam_role-${var.client_name}-ecs_task"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]  
}
EOF

  inline_policy {
    name = "cb-iam_policy-${var.client_name}-ecs_task"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": [
        "${data.aws_secretsmanager_secret.docker_credentials.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "secretsmanager:ListSecrets",
      "Resource": "*"
    }
  ]
}
EOF
  }
  tags = merge(
    { Name        = "cb-iam_role-${var.client_name}-ecs_task" },
    local.common_tags
  )
}




resource "aws_iam_role" "healthcheck-execution_role" {
  name = "cb-iam_role-${var.client_name}-healthcheck_task"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]  
}
EOF

  inline_policy {
    name = "cb-iam_policy-${var.client_name}-healthcheck_task"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": [
        "${data.aws_secretsmanager_secret.docker_credentials.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "cloudwatch:PutMetricData",
      "Resource": "*"
    }
  ]
}
EOF
  }
  tags = merge(
    { Name        = "cb-iam_role-${var.client_name}-ecs_task" },
    local.common_tags
  )
}
