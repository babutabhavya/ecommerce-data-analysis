# Define EMR Service Role
resource "aws_iam_role" "emr_service_role" {
  name               = "EMR_DefaultRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "elasticmapreduce.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "emr_service_policy_attachment" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

# IAM role for EMR EC2 instances
resource "aws_iam_role" "emr_ec2_role" {
  name               = "EMR_EC2_DefaultRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Instance profile for EMR EC2 instances
resource "aws_iam_instance_profile" "emr_ec2_instance_profile" {
  name = "EMR_EC2_DefaultInstanceProfile"
  role =  aws_iam_role.emr_ec2_role.name

}

# Fetch the public IP address using an external HTTP data source
data "http" "my_ip" {
  url = "http://checkip.amazonaws.com/"
}

# Extract the IP address from the HTTP response
locals {
  my_public_ip = trimspace(data.http.my_ip.response_body)
}

# EMR Security Group for Master
resource "aws_security_group" "emr_master" {
  name        = "emr_master_sg"
  description = "Allow SSH access to EMR master node"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_public_ip}/32"]  # Allow SSH only from your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EMR Security Group for Slave
resource "aws_security_group" "emr_slave" {
  name        = "emr_slave_sg"
  description = "Allow all traffic for EMR slave nodes"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${local.my_public_ip}/32"]  # Allow SSH only from your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_emr_cluster" "emr_cluster" {
  name          = "emr-cluster"
  release_label = "emr-6.5.0"
  applications  = ["Hadoop", "Hive", "Hue", "Spark", "Pig"]

  service_role = aws_iam_role.emr_service_role.name

  ec2_attributes {
    key_name                         = var.key_name
    instance_profile                 = aws_iam_instance_profile.emr_ec2_instance_profile.name
    emr_managed_master_security_group = aws_security_group.emr_master.id
    emr_managed_slave_security_group  = aws_security_group.emr_slave.id
  }

  master_instance_group {
    instance_type = var.master_instance_type
  }

  core_instance_group {
    instance_type = var.core_instance_type
    instance_count = var.core_instance_count
  }

#   bootstrap_action {
#     name = "Install libraries"
#     path = "s3://my-bootstrap-bucket/install-libraries.sh"
#   }

#   configurations_json = <<EOF
# [
#   {
#     "Classification": "hue-site",
#     "Properties": {
#       "hue.https.enabled": "false"
#     }
#   }
# ]
# EOF

  tags = {
    Name = "emr-cluster-${var.environment}"
  }
}
