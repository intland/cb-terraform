data "aws_secretsmanager_secret" "docker_credentials" {
  name = var.docker_credentials
}
data "aws_secretsmanager_secret_version" "docker_credentials" {
  secret_id = data.aws_secretsmanager_secret.docker_credentials.id
}

data "aws_ssm_parameter" "db_pass" {
  name = "/ecscb/parameters/${var.client_name}/db-password"
  with_decryption = true
}

data "aws_ssm_parameter" "keystore_pass" {
  name = "/ecscb/parameters/${var.client_name}/tomcat-keystore-password"
  with_decryption = true
}

data "aws_ssm_parameter" "ec2_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

data "aws_s3_bucket" "client_resources" {
  bucket = "client-resources"
}
data "aws_s3_bucket" "home_resources" {
  bucket = "home-resources"
}
variable "backup_plan_id" {}
variable "cb_context_path" {}
variable "cb_environment" {}
variable "cb_image" {}
variable "cb_version" {}
variable "client_database_engine" {}
variable "client_database_host" {}
variable "client_database_port" {}
variable "client_name" {}
variable "client_url" {}
variable "db_username" {}
variable "docker_credentials" {}
variable "inspector_enabled"{}
variable "instance_type" {}
variable "license" {}
variable "media_disk_size" {}
variable "provisioner" {}
variable "rds_name"{}
variable "region_name" {}
variable "schema" {}
variable "snapshot_id" {}
variable "subnet_ids" {}
variable "top_domain" {}
variable "trusted_ips"{}
variable "vpc_id" {}
locals{
  common_tags = {
    Client      = var.client_name,
    Provisioner = var.provisioner,
    Database    = var.rds_name,
    CodeBeamerVersion = var.cb_version
  }
  db_username = var.db_username == "" ? "${var.client_name}_root" : var.db_username
  schema = var.schema == "" ? var.client_name : var.schema 
  database_mappings = {
    postgres = {
      port = "5432",
      url_prefix = "jdbc:postgresql:",
      url_suffix = "",
      JDBC_driver="org.postgresql.Driver"
    },
    mysql = {
      port = "3306",
      url_prefix = "jdbc:mysql:",
      url_suffix = "?autoReconnect=true&zeroDateTimeBehavior=convertToNull&emulateLocators=true&characterEncoding=UTF-8&useSSL=false",
      JDBC_driver="com.mysql.jdbc.Driver"
    }
  }

  cb_cpu = {
    "t3.medium" = 1024,
    "m5.large" = 1024,
    "m5.xlarge" = 2048,
    "m5.2xlarge" = 4096,
    "m5.4xlarge" = 4096
  }
  cb_memory = {
    "t3.medium" = 2048,
    "m5.large" = 4096,
    "m5.xlarge" = 8192,
    "m5.2xlarge" = 16384,
    "m5.4xlarge" = 32768
  }
  key_name = {
    "eu-north-1" = "idrsa",
    "eu-west-2" = "idrsa",
    "eu-west-1" = "idrsa",
    "ap-northeast-1" = "idrsa",
    "ap-southeast-2" = "idrsa",
    "eu-central-1" = "idrsa",
    "us-east-1" = "idrsa",
    "us-east-2" = "idrsa",
    "us-west-2" = "idrsa"
  }
  client_url = var.client_url == "" ? "${var.client_name}.${data.aws_route53_zone.public.name}" : var.client_url
}
