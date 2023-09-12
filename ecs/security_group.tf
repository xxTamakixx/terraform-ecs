########################################
# Security Group
########################################
## web security group ##
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "web front role security group"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "web_in_http" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_in_https" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_out_tcp3000" {
  security_group_id        = aws_security_group.web_sg.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3000
  to_port                  = 3000
  source_security_group_id = aws_security_group.app_sg.id
}

## app security group ##
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "application server role security group"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "app_in_tcp3000" {
  security_group_id        = aws_security_group.app_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3000
  to_port                  = 3000
  source_security_group_id = aws_security_group.web_sg.id
}

# resource "aws_security_group_rule" "app_out_http" {
#   security_group_id = aws_security_group.app_sg.id
#   type              = "egress"
#   protocol          = "tcp"
#   from_port         = 80
#   to_port           = 80
#   prefix_list_ids   = [data.aws_prefix_list.s3_pl.id]
# }

# resource "aws_security_group_rule" "app_out_https" {
#   security_group_id = aws_security_group.app_sg.id
#   type              = "egress"
#   protocol          = "tcp"
#   from_port         = 443
#   to_port           = 443
#   prefix_list_ids   = [data.aws_prefix_list.s3_pl.id]
# }

resource "aws_security_group_rule" "app_out_tcp3306" {
  security_group_id        = aws_security_group.app_sg.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.db_sg.id
}

## db security group ##
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "database role security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.app_sg.id]
  }
}
