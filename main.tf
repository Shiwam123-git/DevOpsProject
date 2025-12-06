# ------------------------------
# Provider
# ------------------------------
provider "aws" {
  region = "us-east-1"
}

# ------------------------------
# ECR Repository
# ------------------------------
resource "aws_ecr_repository" "my_app" {
  name                 = "my-static-tomcat"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "Dev"
    Project     = "StaticTomcatSite"
  }
}

# ------------------------------
# IAM Policy for Jenkins
# ------------------------------
data "aws_iam_policy_document" "jenkins_ecr" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:ListImages"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_user" "jenkins_user" {
  name = "jenkins-user"
}

resource "aws_iam_user_policy" "jenkins_policy" {
  name   = "jenkins-ecr-policy"
  user   = aws_iam_user.jenkins_user.name
  policy = data.aws_iam_policy_document.jenkins_ecr.json
}

# Optional: IAM access key for Jenkins
resource "aws_iam_access_key" "jenkins_key" {
  user = aws_iam_user.jenkins_user.name
}

# ------------------------------
# Outputs
# ------------------------------
output "ecr_repository_uri" {
  value = aws_ecr_repository.my_app.repository_url
}

output "jenkins_access_key_id" {
  value = aws_iam_access_key.jenkins_key.id
}

