# Codebeamer on AWS with terraform

This template is dependent on some resources that must be present in the target AWS account before deployment. Some of these resources can be omitted but in order to do that, code change is required.

These resources include:
* RDS DB instance
  * if you don't want to use RDS, remove the network/rds.tf file and add the following envs to codebeamer:
    * WAIT_HOSTS
    * CB_database_JDBC_ConnectionURL
    * CB_database_JDBC_Driver
  * if you use RDS, vpc peering will be created, subnet ranges must not conflict
  * DB must have codebeamer schema set up (see below)
* Docker Secrets
  * dockerhub credentials for pulling images
  * also access to images
* AWS Parameters
  * "/ecscb/parameters/${var.client_name}/db-password"
    * Type: SecureString
    * must match password for the db user
  * "/ecscb/parameters/${var.client_name}/tomcat-keystore-password"
    * Type: SecureString
    * Needed for TLS if you use tomcat
    * Must be set even if not used, or definition must be removed from compute/vars.tf
* Route53 Zone
  * update compute/route53.tf to use your domain

To set up a schema for codebeamer in postgres, issue the following commands:
```
CREATE DATABASE "database schema" LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' ENCODING 'UTF8' TEMPLATE = template0;
CREATE USER "database user" WITH PASSWORD 'database password';
ALTER DATABASE "database schema" OWNER TO "database user";
```

TLS isn't configured, you can reach the application on http port 80 of the EC2 instance. If you need TLS, configure tomcat or add TLS offload (loadbalancer, sidecar container)

Before starting the deployment, update (or remove) the init.tf file to set a backend.

When you delete the deployment, you have to manually delete the autoscaling group created, else the stack deletion will fail.