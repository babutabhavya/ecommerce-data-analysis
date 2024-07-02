terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

module "key" {
  source   = "../../components/aws/keys"
  key_name = "private_key"

}

# module "ec2" {
#   depends_on = [ module.key ]
#   source           = "../../components/aws/ec2"
#   environment      = var.environment
#   instance_type    = var.instance_type
#   private_key_name = module.key.private_key_name
# }

module "data_analysis_data_store" {
  source      = "../../components/aws/s3"
  bucket_name = "data-analysis-ecommerce"
  environment = var.environment
}

module "emr_bucket_logs" {
  source      = "../../components/aws/s3"
  bucket_name = "emr-logs-data-analysis"
  environment = var.environment
}

module "dataset-obj" {
  source     = "../../components/aws/s3/s3_object"
  depends_on = [module.data_analysis_data_store]
  s3_bucket  = module.data_analysis_data_store.bucket_id
  key        = "olist_public_dataset.csv"
  obj_source = "${path.module}/files/olist_public_dataset.csv"
}

module "emr-output-obj" {
  source     = "../../components/aws/s3/s3_object"
  depends_on = [module.data_analysis_data_store]
  s3_bucket  = module.data_analysis_data_store.bucket_id
  key        = "output/"
  obj_source = ""
}

module "emr-pyspark-code-obj" {
  source     = "../../components/aws/s3/s3_object"
  depends_on = [module.data_analysis_data_store]
  s3_bucket  = module.data_analysis_data_store.bucket_id
  key        = "main.py"
  obj_source = "../../../${path.module}/code/main.py"
}

module "emr_service_role" {
  source = "../../components/aws/role"
  name   = "EMR_DefaultRole"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "elasticmapreduce.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

module "emr_ec2_service_role" {
  source = "../../components/aws/role"
  name   = "EMR_EC2_DefaultRole"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

module "emr" {
  depends_on           = [module.emr_bucket_logs, module.data_analysis_data_store, module.key, module.emr-output-obj, module.emr-pyspark-code-obj, module.emr_service_role]
  source               = "../../components/aws/emr"
  environment          = var.environment
  key_name             = module.key.private_key_name
  logs_uri             = "s3://${module.emr_bucket_logs.bucket_id}"
  pyspark_app_s3_path  = "s3://${module.data_analysis_data_store.bucket_id}/main.py"
  emr_service_role     = module.emr_service_role.name
  emr_ec2_service_role = module.emr_ec2_service_role.name
}

module "glue_catalog_database" {
  depends_on    = [module.emr]
  source        = "../../components/aws/glue/database"
  database_name = "analysis-result"
}

module "glue_crawler_service_policy" {
  source = "../../components/aws/role"
  name   = "AWSGlueCrawler"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

module "glue_orderstatusgroupedbycityandday" {
  source            = "../../components/aws/glue/crawler"
  depends_on        = [module.emr, module.glue_catalog_database, module.glue_crawler_service_policy]
  bucket_folder     = "orderstatusgroupedbycityandday.parquet/"
  s3_bucket_name    = module.data_analysis_data_store.bucket_id
  database_name     = module.glue_catalog_database.name
  name              = "orderstatusgroupedbycityandday"
  service_role_name = module.glue_crawler_service_policy.name
}

module "glue_orderstatusgroupedbycityandweek" {
  source            = "../../components/aws/glue/crawler"
  depends_on        = [module.emr, module.glue_catalog_database, module.glue_crawler_service_policy]
  bucket_folder     = "orderstatusgroupedbycityandweek.parquet/"
  s3_bucket_name    = module.data_analysis_data_store.bucket_id
  database_name     = module.glue_catalog_database.name
  name              = "orderstatusgroupedbycityandweek"
  service_role_name = module.glue_crawler_service_policy.name
}

module "glue_orderstatusgroupedbystateandday" {
  source            = "../../components/aws/glue/crawler"
  depends_on        = [module.emr, module.glue_catalog_database, module.glue_crawler_service_policy]
  bucket_folder     = "orderstatusgroupedbystateandday.parquet/"
  s3_bucket_name    = module.data_analysis_data_store.bucket_id
  database_name     = module.glue_catalog_database.name
  name              = "orderstatusgroupedbystateandday"
  service_role_name = module.glue_crawler_service_policy.name
}

module "glue_orderstatusgroupedbystateandweek" {
  source            = "../../components/aws/glue/crawler"
  depends_on        = [module.emr, module.glue_catalog_database, module.glue_crawler_service_policy]
  bucket_folder     = "orderstatusgroupedbystateandweek.parquet/"
  s3_bucket_name    = module.data_analysis_data_store.bucket_id
  database_name     = module.glue_catalog_database.name
  name              = "orderstatusgroupedbystateandweek"
  service_role_name = module.glue_crawler_service_policy.name
}
