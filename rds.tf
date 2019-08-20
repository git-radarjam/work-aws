# # Creates an RDS MS SQL Database Instance

resource "aws_db_subnet_group" "production_oracle_db_subnet" {
  name        = "oracle db subnet"
  description = "Oracle DB Subnet Group"
  subnet_ids  = ["${aws_subnet.public_subnet1.id}", "${aws_subnet.private_subnet1.id}", "${aws_subnet.private_subnet2.id}"]
  tags = {
    Name = "Production: Oracle Database"
  }
}

##########################
# AWS Oracle DB Instance #
##########################

resource "aws_db_instance" "production_oracle_db" {
  allocated_storage      = 20
  engine                 = "${var.oracle_db_engine}"
  engine_version         = "${var.oracle_db_engine_version}"
  license_model          = "${var.license_type}" # (Oracle = "bring-your-own-license" or "license-included")
  instance_class         = "${var.oracle_instance_type}"
  identifier             = "${var.oracle_identifier}"
  name                   = "${var.oracle_name}"
  username               = "${var.oracle_user}"     # username
  password               = "${var.oracle_password}" # password
  db_subnet_group_name   = "${aws_db_subnet_group.production_oracle_db_subnet.name}"
  multi_az               = "true" # True = to obtain high availability where 2 instances sync with each other.
  vpc_security_group_ids = ["${aws_security_group.allow_oracle.id}"]
  #storage_type            = "standard"
  backup_retention_period = 7
  #apply_immediately       = true
  #availability_zone   = "${aws_subnet.private_subnet1.availability_zone}"
  skip_final_snapshot = true

  tags = {
    Name = "Production: Oracle RDS"
  }
}
