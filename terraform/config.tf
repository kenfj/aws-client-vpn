# you may need environment variables
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
provider "aws" {
  version = "~> 1.58"
  region  = "${var.aws_region}"
}

provider "aws" {
  version = "~> 1.58"
  alias   = "cvpn"
  region  = "${var.client_vpn_region}"
}

terraform {
  required_version = "~> 0.11.11"

  # backend "s3" {
  #   bucket = "some-bucket"
  #   key    = "example/terraform.tfstate"
  #   region = "ap-northeast-1"
  # }
}
