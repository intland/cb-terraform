data "aws_db_instance" "db" {
  db_instance_identifier = var.rds_name
}
data "aws_db_subnet_group" "db" {
  name = data.aws_db_instance.db.db_subnet_group
}
data "aws_vpc" "db" {
  id = data.aws_db_subnet_group.db.vpc_id
}

resource "aws_security_group_rule" "cb-rds-db_access" {
  security_group_id = data.aws_db_instance.db.vpc_security_groups[0]
  type              = "ingress"
  from_port         = local.db_port_map[data.aws_db_instance.db.engine]
  to_port           = local.db_port_map[data.aws_db_instance.db.engine]
  protocol          = "tcp"
  cidr_blocks       = [ aws_vpc.main.cidr_block ]
  description       = "DB Access for ${var.client_name}"
}

resource "aws_vpc_peering_connection" "cb-to-db" {
  peer_vpc_id   = data.aws_vpc.db.id
  vpc_id        = aws_vpc.main.id
  auto_accept = true
}
resource "aws_route" "cb-to-db" {
  route_table_id = aws_route_table.main.id
  destination_cidr_block = data.aws_vpc.db.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.cb-to-db.id
}
resource "aws_route" "db-to-cb" {
  route_table_id = data.aws_vpc.db.main_route_table_id
  destination_cidr_block = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.cb-to-db.id
}

