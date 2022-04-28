resource "aws_eip" "cb" {
  vpc = true
}

data "aws_iam_role" "backup_service" {
  name = "AWSBackupDefaultServiceRole"
}

resource "aws_launch_template" "cb" {
  name          = "cb-ec2_lt-${var.client_name}-cb"
  image_id      = data.aws_ssm_parameter.ec2_ami.value
  instance_type = var.instance_type
  key_name      = local.key_name[var.region_name]

  vpc_security_group_ids = [ aws_security_group.cb.id ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_host.name
  }

  user_data = base64encode(templatefile("${path.module}/../templates/cluster.tpl", {
    client_name="${var.client_name}",
    region_name=var.region_name, 
    inspector_enabled=var.inspector_enabled,
    media_volume=aws_ebs_volume.media.id,
    public_domain=local.client_url,
    public_hosted_zone_id=data.aws_route53_zone.public.zone_id,
    eip_allocation_id=aws_eip.cb.allocation_id,
    docker_username=jsondecode(data.aws_secretsmanager_secret_version.docker_credentials.secret_string)["DOCKER_USERNAME"],
    docker_password=jsondecode(data.aws_secretsmanager_secret_version.docker_credentials.secret_string)["DOCKER_PASSWORD"],
    home_resources_bucket=data.aws_s3_bucket.home_resources.bucket_domain,
    client_resources_bucket=data.aws_s3_bucket.client_resources.bucket_domain
  }))

  tags = merge(
    { Name        = "cb-ec2_lt-${var.client_name}-cb" },
    local.common_tags
  )
}
resource "aws_ebs_volume" "media" {
  availability_zone = data.aws_subnet.cb[0].availability_zone
  snapshot_id = var.snapshot_id == "" ? null : var.snapshot_id
  size = var.snapshot_id == "" ? var.media_disk_size : null
   tags = {
    "backup_group_ebs" = var.client_name
  }
}
resource "aws_backup_selection" "media" {
  count = var.backup_plan_id == "" ? 0 : 1
  iam_role_arn = data.aws_iam_role.backup_service.arn
  name = "ebs-${var.client_name}"
  plan_id = var.backup_plan_id
  resources = [
    aws_ebs_volume.media.arn
  ]
}

data "aws_subnet" "cb" {
  count = length(var.subnet_ids)
  id = var.subnet_ids[count.index]
}
resource "aws_autoscaling_group" "cb" {
  name = "cb-asg-${var.client_name}-cb"
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  vpc_zone_identifier = [data.aws_subnet.cb.0.id]
  launch_template {
    id      = aws_launch_template.cb.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "cb-ec2-${var.client_name}-cb"
  }
  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = ""
  }
}


resource "aws_ecs_capacity_provider" "cb" {
  name = "cb-ecs_cp-${var.client_name}-cb"

  auto_scaling_group_provider{
    auto_scaling_group_arn = aws_autoscaling_group.cb.arn
  }
  tags = merge(
    { Name        = "cb-ecs_cp-${var.client_name}-cb" },
    local.common_tags
  )
}

resource "aws_security_group" "cb" {
  name = "cb-sg-${var.client_name}"
  description = "codebeamer ECS cluster SG"
  vpc_id = var.vpc_id
  ingress {
    description = "Allow all from self"
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    self = true
  }
  ingress {
    description = "Allow ssh"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = [var.trusted_ips]
  }  
  ingress {
    description = "Allow 443"
    from_port = "443"
    to_port = "443"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 80"
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 8080"
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 8090"
    from_port = "8090"
    to_port = "8090"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = merge(
    { Name        = "cb-sg-${var.client_name}" },
    local.common_tags
  )
}