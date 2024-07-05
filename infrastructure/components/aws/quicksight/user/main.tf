resource "aws_quicksight_user" "quicksight_user" {
  email         = var.email
  identity_type = "QUICKSIGHT"
  user_role     = var.role
  user_name     = var.email
}
