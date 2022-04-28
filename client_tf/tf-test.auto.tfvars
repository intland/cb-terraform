instance_type   = "m5.large"
rds_name        = "rds-test-pg"
client_name     = "tf-test"
cb_image        = "intland/codebeamer-git:21.09-lts"
#snapshot_id     = "snap-xyz"
media_disk_size = 300
region_name     = "eu-central-1"
cb_context_path = "cb"

cb_environment = {
  CB_DOCKER_LOGGING="true"
  NOT_ENOUGH_TOTAL_MEMORY_CHECK_ENABLED="false"
  CB_DOCUMENT_STORE_INTO_DB="true"
  TOMCAT_CONNECTOR_HTTP_TO_HTTPS_REDIRECT="false"

  # alternative db connection setup example
  #WAIT_HOSTS="ip-20-11-1-114.eu-central-1.compute.internal:5432"
  #CB_database_JDBC_ConnectionURL="jdbc:postgresql://ip-20-11-1-114.eu-central-1.compute.internal/codebeamer"
  #CB_database_JDBC_Driver="org.postgresql.Driver"
}