### Network
# create VPC + private subnets
# create EC2 instance + ssh security group

data "aws_availability_zones" "az" {}

######################################################################
# VPC
resource "aws_vpc" "main" {
  cidr_block = "${var.main_vpc_cidr}"

  tags {
    Name = "${var.app_name}_vpc_main"
  }
}

resource "aws_subnet" "main_private" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.main_subnet_cidr}"
  availability_zone = "${data.aws_availability_zones.az.names[0]}"

  tags {
    Name = "${var.app_name}_subnet_main"
  }
}

######################################################################
# EC2
resource "aws_instance" "main" {
  ami                    = "ami-0d7ed3ddb85b521a6"                      # Amazon Linux 2
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.main_private.id}"
  availability_zone      = "${data.aws_availability_zones.az.names[0]}"
  vpc_security_group_ids = ["${aws_security_group.main.id}"]
  key_name               = "${var.main_key_pair}"

  tags = {
    Name = "${var.app_name}_vm_main"
  }
}

resource "aws_security_group" "main" {
  name   = "${var.app_name}_sg_main"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "main_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.main.id}"
}

resource "aws_security_group_rule" "main_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.main.id}"
}
