# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !! DO NO EDIT - DO NO EDIT - DO NO EDIT - DO NO EDIT - DO NO EDIT - DO NO EDIT - DO NO EDIT !!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# This file will be automatically deleted by the codebuild project
#   This particular file is a copy of terraform_provider.tf in src/infrastructure
#   It needs to be kept in sync with that file for local debugging to work!

# This is a global file that is copied into each project directory by the buildspec file

################################################################################
# Variables with UPPERCASE names are set through environment variables TF_VAR_<NAME> in the devops pipeline
# Variables with lowercase names are set via *.tfvars files
#-------------------------------------------------------------------------------

variable "APP_PROJECT" {
  description = "Name of the project"
}

variable "APP_SUBPROJECT" {
  description = "Name of the country / common project (eg. br, de, init, shared)"
}

variable "APP_SUBPROJECT_LIST" {
  description = "List of deployed countries as JSON (ONLY available to non-country projects like ics-init and ics-shared!)"
  default     = "[]"
}

variable "APP_BOUNDARY_ARN" {
  description = "ARN of the permission boundary for all roles"
}

variable "APP_SANITIZATION_TARGET_ACCOUNT" {
  description = "Account ID of the target where the sanitization data is transferred to"
  default     = ""
}

variable "APP_SANITIZATION_SOURCE_ACCOUNT" {
  description = "Account ID of the source where the sanitization data is generated"
  default     = ""
}

variable "AWS_REGION" {
  description = "AWS main region"
}

variable "AWS_BACKUP_REGION" {
  description = "AWS main region"
}

variable "AWS_DEPLOY_PROFILE" {
  description = "Name of the AWS deployment role"
}

################################################################################
# These are data sources / local variables that are common to all countries
#-------------------------------------------------------------------------------

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  stage        = terraform.workspace
  project      = var.APP_PROJECT
  country_list = jsondecode(var.APP_SUBPROJECT_LIST)
  country      = local.country_list == [] ? var.APP_SUBPROJECT : null
  boundary_arn = var.APP_BOUNDARY_ARN
  base_settings = {
    stage                       = local.stage
    project                     = local.project
    boundary_arn                = local.boundary_arn
    sanitization_target_account = var.APP_SANITIZATION_TARGET_ACCOUNT
    sanitization_source_account = var.APP_SANITIZATION_SOURCE_ACCOUNT
  }
}

################################################################################

# This provider works directly in the target account with the deployment role
provider "aws" {
  region  = var.AWS_REGION
  profile = var.AWS_DEPLOY_PROFILE
  assume_role {
    session_name = "${var.APP_PROJECT}-${terraform.workspace}"
  }
}

provider "aws" {
  alias   = "dr"
  region  = var.AWS_BACKUP_REGION
  profile = var.AWS_DEPLOY_PROFILE
  assume_role {
    session_name = "${var.APP_PROJECT}-${terraform.workspace}"
  }
}

provider "archive" {}

provider "dns" {}

provider "external" {}

provider "null" {}

terraform {
  required_providers {
    archive = {
      version = "~> 2.2.0"
      source  = "hashicorp/archive"
    }
    aws = {
      version = "~> 3.42.0"
      source  = "hashicorp/aws"
    }
    dns = {
      version = "~> 3.1.0"
      source  = "hashicorp/dns"
    }
    external = {
      version = "~> 2.1.0"
      source  = "hashicorp/external"
    }
    null = {
      version = "~> 3.1.0"
      source  = "hashicorp/null"
    }
  }
  required_version = ">= 0.13"
}
