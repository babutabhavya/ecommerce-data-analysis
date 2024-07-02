resource "aws_glue_catalog_database" "analysis_result_db" {
  name = var.database_name
}