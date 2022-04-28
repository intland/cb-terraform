variable "rds_name" {}
variable "client_name" {}
variable "provisioner" {}
variable "cb_version" {}
variable "region" {}

locals{
  common_tags = {
    Client      = var.client_name,
    Provisioner = var.provisioner,
    Database    = var.rds_name,
    CodeBeamerVersion = var.cb_version
  }
  db_port_map = {
    mysql = 3306
    postgres = 5432
  }
}
