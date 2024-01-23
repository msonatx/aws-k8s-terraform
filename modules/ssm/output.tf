output "k8s_join_param_arn" {
    value = aws_ssm_parameter.k8s_join_token.arn  
}