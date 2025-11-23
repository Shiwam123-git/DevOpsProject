resource "aws_ecs_task_definition" "TD" {

  family                   = "AppTaskDefinition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"

  container_definitions = jsonencode([{
    name      = "my-app-container"
    image     = "nginx:latest"
    essential = true
    cpu       = 1024
    memory    = 2048
    portMappings = [{
      containerport = 80
      hostport      = 80
      protocol      = "tcp"

    }]
  }])

}

data "aws_ecs_task_definition" "TD" {
  task_definition = aws_ecs_task_definition.TD.family
}