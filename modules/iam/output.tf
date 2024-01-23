output "k8s_ec2_instance_profile" {
  value = aws_iam_instance_profile.k8s_instance_profile.name
}