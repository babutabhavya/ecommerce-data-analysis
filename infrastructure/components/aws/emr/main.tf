
resource "aws_iam_role_policy_attachment" "emr_service_policy_attachment" {
  role       = var.emr_service_role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}


# Create policy for S3 bucket access
resource "aws_iam_policy" "emr_s3_policy" {
  name        = "EMR_S3_Access_Policy"
  description = "Policy to allow EMR cluster access to specific S3 buckets"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "*",
        "Resource" : "arn:aws:s3:::*"
      }
    ]
  })
}

# Attach the S3 access policy to the EMR EC2 role
resource "aws_iam_role_policy_attachment" "emr_ec2_policy_attachment" {
  role       = var.emr_ec2_service_role
  policy_arn = aws_iam_policy.emr_s3_policy.arn
}

# Instance profile for EMR EC2 instances
resource "aws_iam_instance_profile" "emr_ec2_instance_profile" {
  name = "EMR_EC2_DefaultInstanceProfile"
  role = var.emr_ec2_service_role

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
    cidr_blocks = ["${local.my_public_ip}/32"] # Allow SSH only from your IP
  }

  ingress {
    from_port   = 9870
    to_port     = 9870
    protocol    = "tcp"
    cidr_blocks = ["${local.my_public_ip}/32"] # Allow SSH only from your IP
  }

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["${local.my_public_ip}/32"] # Allow SSH only from your IP
  }

  ingress {
    from_port   = 18080
    to_port     = 18080
    protocol    = "tcp"
    cidr_blocks = ["${local.my_public_ip}/32"] # Allow SSH only from your IP
  }

  ingress {
    from_port   = 9864
    to_port     = 9864
    protocol    = "tcp"
    cidr_blocks = ["${local.my_public_ip}/32"] # Allow SSH only from your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
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
    protocol    = "all"
    cidr_blocks = ["${local.my_public_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow all traffic from master to slave
resource "aws_security_group_rule" "allow_master_to_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  security_group_id        = aws_security_group.emr_slave.id
  source_security_group_id = aws_security_group.emr_master.id
}

# Allow all traffic from slave to master
resource "aws_security_group_rule" "allow_slave_to_master" {
  depends_on               = [aws_security_group.emr_slave, aws_security_group.emr_master]
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  security_group_id        = aws_security_group.emr_master.id
  source_security_group_id = aws_security_group.emr_slave.id
}


resource "aws_emr_cluster" "emr_cluster" {
  name          = "emr-cluster"
  release_label = "emr-6.5.0"
  applications  = ["Hadoop", "Hive", "Spark"]

  service_role = var.emr_service_role
  log_uri      = var.logs_uri


  ec2_attributes {
    key_name                          = var.key_name
    instance_profile                  = aws_iam_instance_profile.emr_ec2_instance_profile.name
    emr_managed_master_security_group = aws_security_group.emr_master.id
    emr_managed_slave_security_group  = aws_security_group.emr_slave.id
  }

  master_instance_group {
    instance_type = var.master_instance_type
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = var.core_instance_count
  }

  step {
    name              = "Run PySpark Application"
    action_on_failure = "CANCEL_AND_WAIT"
    hadoop_jar_step {
      jar = "command-runner.jar"
      args = [
        "spark-submit",
        "--deploy-mode", "cluster",
        var.pyspark_app_s3_path
      ]
    }
  }

  configurations_json = <<EOF
    [
      {
        "Classification": "yarn-site",
        "Properties": {
          "yarn.scheduler.maximum-allocation-mb": "4096",
          "yarn.nodemanager.resource.memory-mb": "8192"
        }
      }
    ]
EOF

  tags = {
    Name = "emr-cluster-${var.environment}"
  }
  lifecycle {
    ignore_changes = [step, ec2_attributes]
  }
}


resource "null_resource" "wait_for_step" {
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      while true; do
        step_id=$(aws emr list-steps --region us-east-1 --cluster-id ${aws_emr_cluster.emr_cluster.id} --query 'Steps[0].Id' --output text)
        if [ -n "$step_id" ]; then
          step_status=$(aws emr describe-step --region us-east-1 --cluster-id ${aws_emr_cluster.emr_cluster.id} --step-id "$step_id" --query 'Step.Status.State' --output text)
          if [ "$step_status" == "COMPLETED" ] || [ "$step_status" == "FAILED" ] || [ "$step_status" == "CANCELLED" ]; then
            echo "Step completed with status: $step_status"
            exit 0
          fi
        else
          echo "Step ID not available yet. Waiting..."
        fi
        sleep 30
      done
    EOT
  }

  depends_on = [aws_emr_cluster.emr_cluster]
}
