output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = tolist(aws_subnet.main.*.id)
}


output "client_database_host" {
  value = data.aws_db_instance.db.address
}
output "client_database_port" {
  value = data.aws_db_instance.db.port
}
output "client_database_engine" {
  value = data.aws_db_instance.db.engine
}