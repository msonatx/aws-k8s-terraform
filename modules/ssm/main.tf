resource "aws_ssm_parameter" "k8s_join_token" {
  name  = var.k8s_join_token_name
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [ value ]
  }
}