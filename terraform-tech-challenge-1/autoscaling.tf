

resource "aws_appautoscaling_target" "ecs_appauto_front" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.frontend_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = {
    Project = "Tech-Challenge-1"
  }


}

resource "aws_appautoscaling_policy" "ecs_appauto_policy_front" {
  name               = "frontend-scale-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_appauto_front.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_appauto_front.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_appauto_front.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 15
  }




}




resource "aws_appautoscaling_target" "ecs_appauto_back" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.backend_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"


  tags = {
    Project = "Tech-Challenge-1"
  }

}



resource "aws_appautoscaling_policy" "ecs_appauto_policy_back" {
  name               = "backend-scale-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_appauto_back.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_appauto_back.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_appauto_back.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 15
  }



}
