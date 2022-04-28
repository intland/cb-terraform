data "aws_caller_identity" "current" {}

#Required vars
variable "cb_image" {}
variable "client_name" {}
variable "docker_credentials" {}
variable "instance_type" {}
variable "rds_name"{}
variable "region_name" {}
variable "top_domain" {}
variable "trusted_ips"{}

#Optional vars
variable "backup_plan_id" {
  default = ""
}
variable "cb_context_path" {
  default = ""
}
variable "cb_environment" {
  default = {}
}
variable "client_url" {
  default = ""
}
variable "db_username" {
  default = ""
}
variable "inspector_enabled"{
  default = "true"
}
variable "license" {
  default = ""
}
variable "media_disk_size" {
  default = 0
}
variable "schema" {
  default = ""
}
variable "snapshot_id" {
  default = "" 
}

locals {
  provisioner = reverse(split(":", data.aws_caller_identity.current.arn))[0]
  cb_version  = reverse(split(":", var.cb_image))[0]
}