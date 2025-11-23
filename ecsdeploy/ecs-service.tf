resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.TD.arn

  desired_count       = 2
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  depends_on                         = [aws_lb_listener.listener, aws_iam_role.iam_role]

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "my-app-container"
    container_port   = 80
  }



  network_configuration {
    subnets          = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
    assign_public_ip = true
  }

  tags = {
    Name = "ecs-service"
  }
}