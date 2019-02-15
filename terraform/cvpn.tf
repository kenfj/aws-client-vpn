# client VPN endpoint
# https://blog.adachin.me/archives/9813
# refer outputs.tf to manual setup of Authorization
data "aws_acm_certificate" "cert" {
  provider = "aws.cvpn"
  domain   = "${var.certificate_name}"
  statuses = ["ISSUED"]
}

resource "aws_ec2_client_vpn_endpoint" "example" {
  provider               = "aws.cvpn"
  description            = "${var.app_name}_cvpn_endpoint"
  server_certificate_arn = "${data.aws_acm_certificate.cert.arn}"
  client_cidr_block      = "${var.cvpn_cidr}"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = "${data.aws_acm_certificate.cert.arn}"
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = "${aws_cloudwatch_log_group.lg.name}"
    cloudwatch_log_stream = "${aws_cloudwatch_log_stream.ls.name}"
  }
}

resource "aws_ec2_client_vpn_network_association" "example" {
  provider               = "aws.cvpn"
  client_vpn_endpoint_id = "${aws_ec2_client_vpn_endpoint.example.id}"
  subnet_id              = "${aws_subnet.peer_private.id}"
}

resource "aws_cloudwatch_log_group" "lg" {
  provider          = "aws.cvpn"
  name              = "${var.log_group_name}"
  retention_in_days = 0
}

resource "aws_cloudwatch_log_stream" "ls" {
  provider       = "aws.cvpn"
  name           = "${var.log_stream_name}"
  log_group_name = "${aws_cloudwatch_log_group.lg.name}"
}
