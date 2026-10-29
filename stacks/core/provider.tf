# Terraform stack for local Moto (created from my-local-aws-cloud/templates/project).
# To deploy the same stack to real AWS later, swap this provider block for a real one
# (profile/region, no endpoints); the modules and resources stay the same.
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test" # dummy: real AWS rejects these, so a wrong endpoint cannot reach an account
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3             = var.moto_endpoint
    sts            = var.moto_endpoint
    iam            = var.moto_endpoint
    kinesis        = var.moto_endpoint
    firehose       = var.moto_endpoint
    sqs            = var.moto_endpoint
    sns            = var.moto_endpoint
    dynamodb       = var.moto_endpoint
    ssm            = var.moto_endpoint
    secretsmanager = var.moto_endpoint
    kms            = var.moto_endpoint
    lambda         = var.moto_endpoint
    events         = var.moto_endpoint
    glue           = var.moto_endpoint
    cloudwatch     = var.moto_endpoint
    logs           = var.moto_endpoint
  }

  default_tags {
    tags = {
      Environment        = "local"
      Owner              = var.owner
      CostCenter         = "none"
      Project            = var.project
      BusinessUnit       = "none"
      DataClassification = "internal"
      AutoShutdown       = "n/a"
      ManagedBy          = "terraform"
    }
  }
}
