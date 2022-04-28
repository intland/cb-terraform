module "network" {
  source = "./tf_files/network"
  rds_name = var.rds_name
  cb_version = local.cb_version
  provisioner = local.provisioner
  client_name = var.client_name
  region = var.region_name
}

module "compute" {
  source = "./tf_files/compute"
  backup_plan_id          = var.backup_plan_id
  cb_context_path         = var.cb_context_path
  cb_environment          = var.cb_environment
  cb_image                = var.cb_image
  cb_version              = local.cb_version
  client_database_engine  = module.network.client_database_engine
  client_database_host    = module.network.client_database_host
  client_database_port    = module.network.client_database_port
  client_name             = var.client_name
  client_url              = var.client_url
  db_username             = var.db_username
  docker_credentials      = var.docker_credentials
  inspector_enabled       = var.inspector_enabled
  instance_type           = var.instance_type
  license                 = var.license
  media_disk_size         = var.media_disk_size
  provisioner             = local.provisioner
  rds_name                = var.rds_name
  region_name             = var.region_name
  schema                  = var.schema
  snapshot_id             = var.snapshot_id
  subnet_ids              = module.network.subnet_ids
  top_domain              = var.top_domain
  trusted_ips             = var.trusted_ips
  vpc_id                  = module.network.vpc_id
}
