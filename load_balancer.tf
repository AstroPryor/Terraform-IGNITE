resource "aws_security_group" "alb" {
    name   = "astro-alb-sg"
    vpc_id = aws_vpc.example.id

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Astro - ALB SG"
    }
}

resource "aws_lb" "app" {
    name               = "astro-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb.id]
    subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]

    tags = {
        Name = "Astro - ALB"
    }
}

resource "aws_lb_target_group" "app" {
    name        = "astro-app-tg"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.example.id
    target_type = "ip"

    health_check {
        path                = "/"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 15
        timeout             = 5
    }

    tags = {
        Name = "Astro - App Target Group"
    }
}

resource "aws_lb_listener" "app" {
    load_balancer_arn = aws_lb.app.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app.arn
    }
}
