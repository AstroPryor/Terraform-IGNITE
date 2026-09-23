resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
    alarm_name          = "astro-app-cpu-high"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods   = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/ECS"
    period              = 300
    statistic           = "Average"
    threshold           = 80

    dimensions = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.app.name
    }

    alarm_description = "Triggers when astro-app-service average CPU utilization exceeds 80% for 10 minutes"
    treat_missing_data = "notBreaching"
}
