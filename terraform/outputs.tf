# need to add each vpc cidr to client VPN Authorization tab
output "client_vpn_authorization_cvpn_vpc" {
  value = "${aws_vpc.peer.cidr_block}"
}

output "client_vpn_authorization_main_vpc" {
  value = "${aws_vpc.main.cidr_block}"
}

output "main_private_ip" {
  value = "${aws_instance.main.private_ip}"
}

output "peer_private_ip" {
  value = "${aws_instance.peer.private_ip}"
}
