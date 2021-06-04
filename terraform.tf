terraform {
  backend "s3" {
    bucket         = "alsac-tfstate-util"
    key            = "jenkins/infrastructure.tfstate"
    region         = "us-east-1"
    dynamodb_table = "alsac-tfstate-lock-util"
    encrypt        = true
    # May be needed depending on login method
    profile        = "saml"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0,!= 3.20"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 3.0,!= 3.20"
  # May be needed depending on login method
  profile = "saml"
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
  version = "~> 3.0,!= 3.20"
  # May be needed depending on login method
  profile = "saml"
}

provider "aws" {
  alias  = "usw2"
  region = "us-west-2"
  version = "~> 3.0,!= 3.20"
  # May be needed depending on login method
  profile = "saml"
}