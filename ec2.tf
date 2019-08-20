# Adds hostmachine's keypair to enable SSH
resource "aws_key_pair" "intime-ws" {
  key_name   = "Workstation Keypair"
  public_key = "${file("${var.public_key_path}")}"
}


# Deploys AWS EC2 Instance

resource "aws_instance" "production_ec2" {
  ami                    = "${var.ami}"
  instance_type          = "${var.ec2_instance_type}"
  key_name               = "${aws_key_pair.intime-ws.id}"
  subnet_id              = "${aws_subnet.public_subnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.production_sg.id}"]
  #security_groups = ["${aws_security_group.terra_sg.Name}"]
  #count                       = "${var.instance_count}" #Change count on variables
  associate_public_ip_address = true
  source_dest_check           = false

  root_block_device {}

  tags = {
    Name = "Production EC2"
  }
}
