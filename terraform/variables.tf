variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-northeast-1"
}

variable "client_vpn_region" {
  description = "client vpn available region"
  default     = "us-west-2"
}

variable "app_name" {
  default = "cvpn_test"
}

variable "main_vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "main_subnet_cidr" {
  default = "10.10.0.0/24"
}

variable "main_key_pair" {}

variable "cvpn_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "cvpn_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "cvpn_key_pair" {}

# client vpn settings
variable "certificate_name" {
  default = "server"
}

variable "cvpn_cidr" {
  default = "10.110.0.0/22"
}

variable "log_group_name" {
  default = "/client-vpn"
}

variable "log_stream_name" {
  default = "cvpn-endpoint-us-west-2-log-stream"
}
