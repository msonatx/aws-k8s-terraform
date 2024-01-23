resource "aws_iam_role" "k8s_ec2_instances" {
  name = "k8s_ec2_instances"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "read_k8s_join_param"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:PutParameter"
          ]
          Effect   = "Allow"
          Resource = var.k8s_join_param_arn
        },
      ]
    })
  }

  tags = {
    Name = "k8s_ec2_instances"
  }
}

resource "aws_iam_instance_profile" "k8s_instance_profile" {
  name = "k8s_instance_profile"

  role = aws_iam_role.k8s_ec2_instances.name
}