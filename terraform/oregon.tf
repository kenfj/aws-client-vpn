### Network
# create VPC + private subnets
# create EC2 instance + ssh security group

data "aws_availability_zones" "peer_az" {
  provider = "aws.cvpn"
}

######################################################################
# VPC
resource "aws_vpc" "peer" {
  provider   = "aws.cvpn"
  cidr_block = "${var.cvpn_vpc_cidr}"

  tags {
    Name = "${var.app_name}_vpc_cvpn"
  }
}

resource "aws_subnet" "peer_private" {
  provider          = "aws.cvpn"
  vpc_id            = "${aws_vpc.peer.id}"
  cidr_block        = "${var.cvpn_subnet_cidr}"
  availability_zone = "${data.aws_availability_zones.peer_az.names[0]}"

  tags {
    Name = "${var.app_name}_subnet_cvpn"
  }
}

######################################################################
# EC2
resource "aws_instance" "peer" {
  provider               = "aws.cvpn"
  ami                    = "ami-032509850cf9ee54e"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.peer_private.id}"
  availability_zone      = "${data.aws_availability_zones.peer_az.names[0]}"
  vpc_security_group_ids = ["${aws_security_group.peer.id}"]
  key_name               = "${var.cvpn_key_pair}"

  tags = {
    Name = "${var.app_name}_vm_cvpn"
  }
}

resource "aws_security_group" "peer" {
  provider = "aws.cvpn"
  name     = "${var.app_name}_sg_cvpn"
  vpc_id   = "${aws_vpc.peer.id}"
}

resource "aws_security_group_rule" "peer_ingress" {
  provider    = "aws.cvpn"
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.peer.id}"
}

resource "aws_security_group_rule" "peer_egress" {
  provider    = "aws.cvpn"
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.peer.id}"
}
