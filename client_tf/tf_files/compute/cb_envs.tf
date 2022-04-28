locals {
  cb_environment = merge(
    {
      CB_CLUSTER_ENABLED="false"
      WAIT_HOSTS="${var.client_database_host}:${local.database_mappings[var.client_database_engine]["port"]}"
      CB_database_JDBC_Password=data.aws_ssm_parameter.db_pass.value
      CB_database_JDBC_Username=local.db_username
      CB_database_JDBC_ConnectionURL="${local.database_mappings[var.client_database_engine]["url_prefix"]}//${var.client_database_host}/${local.schema}${local.database_mappings[var.client_database_engine]["url_suffix"]}"
      CB_database_JDBC_Driver=local.database_mappings[var.client_database_engine]["JDBC_driver"]
      TOMCAT_CONNECTOR_KEYSTORE_PASS=data.aws_ssm_parameter.keystore_pass.value
      CB_mail_host="#"
      CB_DOCKER_LOGGING="false"
      TZ="Europe/Berlin"
      CB_DOCUMENT_STORE_INTO_DB="true"
      LOG4J_FORMAT_MSG_NO_LOOKUPS="true"
      CB_wordExport_jvmArguments="-Xmx1G"
      JVM_MEMORY_RATIO="0.6"
      CB_MIN_AVAILABLE_MEMORY_PERCENTAGE="90"
      CB_MIN_AVAILABLE_PHYSICAL_MEMORY_PERCENTAGE="0"
      CB_LOGFILE_TTL="3d"
      CB_DOCS_SIZE_CALCULATION="false"
      WAIT_HOSTS_TIMEOUT="120"
      CB_database_JDBC_Timeout="120"
      CB_REDIRECT_TO= var.cb_context_path == "" ?  "https://${local.client_url}/" : "https://${local.client_url}/${var.cb_context_path}/"
      NOT_ENOUGH_TOTAL_MEMORY_CHECK_ENABLED="false"
      CB_LICENSE=var.license
      CB_CONTEXT_PATH=var.cb_context_path
    },
    var.cb_environment
  )
  healthcheck_env = jsonencode([
    for k,v in {
      CLIENT=var.client_name
      DOMAIN=local.client_url
      AWS_DEFAULT_REGION=var.region_name
      CB_CONTEXT_PATH=var.cb_context_path
    } : { name = k, value = v}
  ])
}