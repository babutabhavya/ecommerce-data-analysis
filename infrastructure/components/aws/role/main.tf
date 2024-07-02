resource "aws_iam_role" "service_role" {
  name = "${var.name}ServiceRole"
  assume_role_policy = var.policy
}
