resource "aws_security_group" "main" {
  name        = "${var.env}-${var.component}-sg"
  description = "${var.env}-${var.component}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "DOCDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.component}-sg"
  }
}

resource "aws_docdb_subnet_group" "main" {
  name       = "${var.env}-${var.component}"
  subnet_ids = var.subnets

  tags = {
    Name = "${var.env}-${var.component}"
  }
}

resource "aws_docdb_cluster" "main" {
  cluster_identifier     = "${var.env}-${var.component}-cluster"
  master_username        = data.aws_ssm_parameter.master_username.value
  master_password        = data.aws_ssm_parameter.master_password.value
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_docdb_subnet_group.main.name
  engine                 = "docdb"
  engine_version         = "4.0.0"
  kms_key_id             = var.kms_key_id
  storage_encrypted      = true
  vpc_security_group_ids = [aws_security_group.main.id]
}

resource "aws_docdb_cluster_instance" "main" {
  count              = var.docdb_instance_count
  identifier         = "${var.env}-${var.component}-${count.index}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.docdb_instance_class
}

