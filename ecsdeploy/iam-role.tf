resource "aws_iam_role" "iam_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = file("${path.module}/iam-role.json")

}