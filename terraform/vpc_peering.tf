##################################################
# VPC Peering
# create VPC Peering + route table in each vpc cidr
#
# cross region needs aws_vpc_peering_connection_accepter
# https://www.terraform.io/docs/providers/aws/r/vpc_peering_accepter.html
#
# mutual route tables
# https://qiita.com/takat0-h0rikosh1/items/e322ff7722e9463285df

resource "aws_vpc_peering_connection" "peer" {
  provider    = "aws.cvpn"
  vpc_id      = "${aws_vpc.peer.id}"
  peer_vpc_id = "${aws_vpc.main.id}"
  peer_region = "${var.aws_region}"
  auto_accept = false

  tags = {
    Name = "${var.app_name}_peering_cvpn"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
  auto_accept               = true
}

resource "aws_route_table_association" "peer_private" {
  provider       = "aws.cvpn"
  subnet_id      = "${aws_subnet.peer_private.id}"
  route_table_id = "${aws_route_table.peer_private.id}"
}

resource "aws_route_table" "peer_private" {
  provider = "aws.cvpn"
  vpc_id   = "${aws_vpc.peer.id}"

  route {
    cidr_block                = "${aws_vpc.main.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
  }

  tags = {
    Name = "${var.app_name}_rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.main_private.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block                = "${aws_vpc.peer.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
  }

  tags = {
    Name = "${var.app_name}_rt"
  }
}
