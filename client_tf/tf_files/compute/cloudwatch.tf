data "aws_sns_topic" "alarms" {
  name = "ECSAlarms"
}
data "aws_sns_topic" "restarts" {
  name = "ECSRestart"
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name =  "cb-cw_alarm-${var.client_name}-cpu"
  alarm_description = "Alarm if CPUUtilization exceeds 80 percent"
  metric_name = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 10
  period = 60
  threshold = 90 
  statistic = "Average"
  unit = "Percent"
  namespace = "AWS/EC2"
  alarm_actions = [ data.aws_sns_topic.alarms.arn ]
  ok_actions = [ data.aws_sns_topic.alarms.arn ]
  insufficient_data_actions = [ data.aws_sns_topic.alarms.arn ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.cb.name
  }
  tags = merge(
    local.common_tags,
    {
      Name = "cb-cw_alarm-${var.client_name}-cpu"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name =  "cb-cw_alarm-${var.client_name}-memory"
  alarm_description = "Alarm if MemoryUtilization exceeds 80 percent"
  metric_name = "MemoryUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 10
  period = 60
  threshold = 80 
  statistic = "Average"
  unit = "Percent"
  namespace = "AWS/ECS"
  alarm_actions = [ data.aws_sns_topic.alarms.arn ]
  ok_actions = [ data.aws_sns_topic.alarms.arn ]
  insufficient_data_actions = [ data.aws_sns_topic.alarms.arn ]
  dimensions = {
    ClusterName = aws_ecs_cluster.cb_cluster.name
  }
  tags = merge(
    local.common_tags,
    {
      Name = "cb-cw_alarm-${var.client_name}-memory"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "root_disk" {
  alarm_name =  "cb-cw_alarm-${var.client_name}-root_disk"
  alarm_description = "Alarm if MediaDiskSpaceUtilization exceeds 90 percent"
  metric_name = "DISK_USED"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  period = 300
  threshold = 90 
  statistic = "Average"
  unit = "Percent"
  namespace = "${var.client_name}-CWAgent"
  alarm_actions = [ data.aws_sns_topic.alarms.arn ]
  ok_actions = [ data.aws_sns_topic.alarms.arn ]
  insufficient_data_actions = [ data.aws_sns_topic.alarms.arn ]
  dimensions = {
    path = "/rootfs",
    fstype = "xfs"
  }
  tags = merge(
    local.common_tags,
    {
      Name = "cb-cw_alarm-${var.client_name}-root_disk"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "healthcheck" {
  alarm_name =  "cb-cw_alarm-${var.client_name}-healthcheck"
  alarm_description = "Alarm if HealthcheckError rises"
  metric_name = "HealthcheckError"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  period = 120
  threshold = 0
  statistic = "Minimum"
  unit = "Count"
  namespace = "ECS/Healthcheck"
  treat_missing_data = "breaching"
  alarm_actions = [ data.aws_sns_topic.alarms.arn ]
  ok_actions = [ data.aws_sns_topic.alarms.arn ]
  insufficient_data_actions = [ data.aws_sns_topic.alarms.arn ]
  dimensions = {
    Client = var.client_name
  }
  tags = merge(
    local.common_tags,
    {
      Name = "cb-cw_alarm-${var.client_name}-healthcheck"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "media_disk" {
  alarm_name =  "cb-cw_alarm-${var.client_name}-media_disk"
  alarm_description = "Alarm if MediaDiskSpaceUtilization exceeds 90 percent"
  metric_name = "DISK_USED"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  period = 300
  threshold = 90 
  statistic = "Average"
  unit = "Percent"
  namespace = "${var.client_name}-CWAgent"
  alarm_actions = [ data.aws_sns_topic.alarms.arn ]
  ok_actions = [ data.aws_sns_topic.alarms.arn ]
  insufficient_data_actions = [ data.aws_sns_topic.alarms.arn ]
  dimensions = {
    path = "/rootfs/media/volume",
    fstype = "xfs"
  }
  tags = merge(
    local.common_tags,
    {
      Name = "cb-cw_alarm-${var.client_name}-media_disk"
    }
  )
}

/*
resource "aws_cloudwatch_metric_alarm" "unhealthy_1" {
  alarm_name =  "cb-cw_alarm-${var.client_name}-unhealthy_1"
  alarm_description = "Alarm if HealthcheckError rises"
  metric_name = "HealthcheckError"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 8
  period = 120
  threshold = 0
  statistic = "Minimum"
  unit = "Count"
  namespace = "ECS/Healthcheck"
  treat_missing_data = "breaching"
  alarm_actions = [ data.aws_sns_topic.restarts.arn ]
  dimensions = {
    Client = var.client_name
  }
  tags = merge(
    local.common_tags,
    {
      Name = "cb-cw_alarm-${var.client_name}-unhealthy_1"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_2" {
  alarm_name =  "cb-cw_alarm-${var.client_name}-unhealthy_2"
  alarm_description = "Alarm if HealthcheckError rises"
  metric_name = "HealthcheckError"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 15
  period = 120
  threshold = 0
  statistic = "Minimum"
  unit = "Count"
  namespace = "ECS/Healthcheck"
  treat_missing_data = "breaching"
  alarm_actions = [ data.aws_sns_topic.restarts.arn ]
  dimensions = {
    Client = var.client_name
  }
  tags = merge(
    local.common_tags,
    {
      Name = "cb-cw_alarm-${var.client_name}-unhealthy_2"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_3" {
  alarm_name =  "cb-cw_alarm-${var.client_name}-unhealthy_3"
  alarm_description = "Alarm if HealthcheckError rises"
  metric_name = "HealthcheckError"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 23
  period = 120
  threshold = 0
  statistic = "Minimum"
  unit = "Count"
  namespace = "ECS/Healthcheck"
  treat_missing_data = "breaching"
  alarm_actions = [ data.aws_sns_topic.restarts.arn ]
  dimensions = {
    Client = var.client_name
  }
  tags = merge(
    local.common_tags,
    {
      Name = "cb-cw_alarm-${var.client_name}-unhealthy_3"
    }
  )
}
*/