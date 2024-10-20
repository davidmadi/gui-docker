# add: listener_2
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "gui_docker" {
  name         = "gui_docker"
  force_delete = true
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "app-cluster" # Name your cluster here
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-gui_docker-task" # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "app-gui_docker-task",
      "image": "${aws_ecr_repository.gui_docker.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 9900,
          "hostPort": 9900
        },
        {
          "containerPort": 5901,
          "hostPort": 5901
        },
        {
          "containerPort": 1337,
          "hostPort": 1337,
          "protocol": "udp"
        },
        {
          "containerPort": 6969,
          "hostPort": 6969,
          "protocol": "udp"
        },
        {
          "containerPort": 451,
          "hostPort": 451,
          "protocol": "udp"
        },
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "udp"
        }
      ],
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-create-group": "true",
              "awslogs-group": "/ecs/app-gui_docker-task",
              "awslogs-region": "us-east-1",
              "awslogs-stream-prefix": "ecs"
          },
          "secretOptions": []
      },
      "memory": 8192,
      "cpu": 1024
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # use Fargate as the lauch type
  network_mode             = "awsvpc"    # add the awsvpc network mode as this is required for Fargate
  memory                   = 8192         # Specify the memory the container requires
  cpu                      = 1024         # Specify the CPU the container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "Default VPC"
  }
  force_destroy = true
}

resource "aws_default_subnet" "default_subnet_a" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "us-east-1a"
  force_destroy = true
  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

resource "aws_default_subnet" "default_subnet_b" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "us-east-1b"
  force_destroy = true
  tags = {
    Name = "Default subnet for us-east-1b"
  }
}

resource "aws_security_group" "load_balancer_security_group_1" {
  description = "aws load balance security group 1"
  ingress {
    from_port   = 5901
    to_port     = 5901
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_alb" "application_load_balancer" {
  name               = "load-balancer-dev" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.load_balancer_security_group_1.id}"]
}


resource "aws_lb_target_group" "target_group_1" {
  name        = "target-group-1"
  port        = 5901
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC
}

resource "aws_lb_target_group" "target_group_2" {
  name        = "target-group-2"
  port        = 9900
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC
}

resource "aws_lb_listener" "listener_1" {
  load_balancer_arn = aws_alb.application_load_balancer.arn # Referencing our load balancer
  port              = "5901"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_1.arn # Referencing our tagrte group
  }
}

resource "aws_lb_listener" "listener_2" {
  load_balancer_arn = aws_alb.application_load_balancer.arn # Referencing our load balancer
  port              = "9900"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_2.arn # Referencing our tagrte group
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "app-first-service"                  # Name the  service
  cluster         = aws_ecs_cluster.my_cluster.id        # Reference the created Cluster
  task_definition = aws_ecs_task_definition.app_task.arn # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1 # Set up the number of containers to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_1.arn # Reference the target group
    container_name   = aws_ecs_task_definition.app_task.family
    container_port   = 5901 # Specify the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true                                                # Provide the containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Set up the security group
  }
}

resource "aws_security_group" "service_security_group" {
  description = "aws service security group 100"
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group_1.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "app_url" {
  value = aws_alb.application_load_balancer.dns_name
}