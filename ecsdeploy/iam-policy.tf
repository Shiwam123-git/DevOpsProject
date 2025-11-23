resource "aws_iam_role_policy" "iam_policy" {
  name   = "ecsTaskExecutionRolePolicy"
  role   = aws_iam_role.iam_role.id
  policy = file("${path.module}/iam-policy.json")

}