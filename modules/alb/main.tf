terraform {
  required_version = ">= 0.12"
}

resource "aws_alb" "alb" {
  name            = var.alb_name
  internal        = var.is_internal_alb
  security_groups = [aws_security_group.alb.id]
  subnets         = var.vpc_subnet_ids

  enable_deletion_protection = false
}

resource "aws_alb_listener" "http" {
  count = length(var.http_listener_ports)

  load_balancer_arn = aws_alb.alb.arn
  port              = var.http_listener_ports[count.index]
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = ""
      status_code  = 404
    }
  }
}

resource "aws_alb_listener" "https_acm_cert" {
  count = length(var.https_listener_ports_and_acm_ssl_certs)

  load_balancer_arn = aws_alb.alb.arn
  port              = var.https_listener_ports_and_acm_ssl_certs[count.index]["port"]
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = data.aws_acm_certificate.cert[count.index].arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = ""
      status_code  = 404
    }
  }
}

data "aws_acm_certificate" "cert" {
  count = length(var.https_listener_ports_and_acm_ssl_certs)

  domain   = var.https_listener_ports_and_acm_ssl_certs[count.index]["certificate_domain_name"]
  statuses = ["ISSUED"]
}

resource "aws_security_group" "alb" {
  name   = "${var.alb_name}-alb"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "http_listeners" {
  count = signum(length(var.allowed_inbound_cidr_blocks)) * length(var.http_listener_ports)

  security_group_id = aws_security_group.alb.id

  type      = "ingress"
  from_port = var.http_listener_ports[count.index]
  to_port   = var.http_listener_ports[count.index]
  protocol  = "tcp"

  cidr_blocks = var.allowed_inbound_cidr_blocks
}

resource "aws_security_group_rule" "https_listeners_acm_certs" {
  count = signum(length(var.allowed_inbound_cidr_blocks)) * length(var.https_listener_ports_and_acm_ssl_certs)

  security_group_id = aws_security_group.alb.id

  type      = "ingress"
  from_port = var.https_listener_ports_and_acm_ssl_certs[count.index]["port"]
  to_port   = var.https_listener_ports_and_acm_ssl_certs[count.index]["port"]
  protocol  = "tcp"

  cidr_blocks = var.allowed_inbound_cidr_blocks
}

resource "aws_security_group_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.alb.id

  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}
