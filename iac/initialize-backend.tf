terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.59.0"
    }
  }

  required_version = ">= 1.2.0"
}

resource "aws_s3_bucket" "tf_backend" {
    bucket = "${var.organization_name}-terraform-state"
    tags = {
        Name = "S3 Remote Terraform State Store"
    }
}

resource "aws_s3_bucket_versioning" "tf_backend_versioning" {
    bucket = aws_s3_bucket.tf_backend
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_backend_encryption" {
    bucket = aws_s3_bucket.tf_backend
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_object_lock_configuration" "tf_backend_lock" {
    bucket = aws_s3_bucket.tf_backend
    object_lock_enabled = "Enabled"
}

resource "aws_dynamodb_table" "tf_lock" {
    name           = "${var.organization_name}-terraform-lock"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    tags = {
        "Name" = "DynamoDB Terraform State Lock Table"
    }
}