resource "aws_ecs_cluster" "cb_cluster" {
  name = "cb-ecs_cluster-${var.client_name}"
  capacity_providers = [ aws_ecs_capacity_provider.cb.name ]

  provisioner "local-exec" {
    when = destroy
    command = <<EOF
aws ecs put-cluster-capacity-providers --cluster ${self.name} --capacity-providers [] --default-capacity-provider-strategy []
sleep 120
aws ecs delete-cluster --cluster ${self.name}
EOF
  }
  tags = merge(
    { Name        = "cb-ecs_cluster-${var.client_name}" },
    local.common_tags
  )
}

locals {
  cb_env = jsonencode([for k, v in local.cb_environment: { name = k, value = v}])
}
resource "aws_ecs_task_definition" "cb" {
  network_mode = "bridge"
  requires_compatibilities = []
  family = "cb-ecs_td-${var.client_name}-cb"
  execution_role_arn = aws_iam_role.ecs_task.arn
  container_definitions = templatefile("${path.module}/../templates/cb_task_definition.json.tpl", {
    CbImage=var.cb_image,
    CbMemory=local.cb_memory[var.instance_type],
    CbCPU=local.cb_cpu[var.instance_type],
    CbEnvironment=local.cb_env,
    CredentialsParameter=data.aws_secretsmanager_secret.docker_credentials.arn
  })
  tags = merge(
    { Name        = "cb-ecs_td-${var.client_name}-cb" },
    local.common_tags
  )

  volume {
    name = "codebeamer-app-repository-scmloop"
    docker_volume_configuration {
      scope         = "task"
      driver        = "local"
      driver_opts   = {}
      labels        = {}
    }
  }
  dynamic "volume" {
    for_each = jsondecode(file("${path.module}/../templates/cb_volumes_definitions.json"))
    content {
      name = volume.value["name"]
      host_path = volume.value["host"]["sourcePath"]
    }
  }
}

resource "aws_ecs_service" "cb" {
  name = "cb-ecs_service-${var.client_name}-cb"
  cluster = aws_ecs_cluster.cb_cluster.arn
  task_definition = aws_ecs_task_definition.cb.arn
  desired_count = 1
  tags = merge(
    { Name        = "cb-ecs_service-${var.client_name}-cb" },
    local.common_tags
  )
}

resource "aws_ecs_task_definition" "hc" {
  network_mode = "bridge"
  requires_compatibilities = []
  family = "cb-ecs_td-${var.client_name}-healthcheck"
  execution_role_arn = aws_iam_role.healthcheck-execution_role.arn
  container_definitions = templatefile("${path.module}/../templates/hc_task_definition.json.tpl", {
    Image="intland/utils:ecs-healthcheck-1.1",
    Environment=local.healthcheck_env,
    CredentialsParameter=data.aws_secretsmanager_secret.docker_credentials.arn
  })
  tags = merge(
    { Name        = "cb-ecs_td-${var.client_name}-healthcheck" },
    local.common_tags
  )
}

resource "aws_ecs_service" "hc" {
  name = "cb-ecs_service-${var.client_name}-healthcheck"
  cluster = aws_ecs_cluster.cb_cluster.arn
  task_definition = aws_ecs_task_definition.hc.arn
  desired_count = 1
  tags = merge(
    { Name        = "cb-ecs_service-${var.client_name}-healthcheck" },
    local.common_tags
  )
}

data "aws_ecs_task_definition" "cw_agent" {
  task_definition = "arn:aws:ecs:${var.region_name}:${data.aws_caller_identity.current.account_id}:task-definition/cwagent:1"
}

resource "aws_ecs_service" "cw_agent_master" {
  name = "cb-ecs_service-${var.client_name}-cw_agent"
  cluster = aws_ecs_cluster.cb_cluster.arn
  task_definition = data.aws_ecs_task_definition.cw_agent.arn
  desired_count = 1
  tags = merge(
    { Name        = "cb-ecs_service-${var.client_name}-cw_agent" },
    local.common_tags
  )
}
