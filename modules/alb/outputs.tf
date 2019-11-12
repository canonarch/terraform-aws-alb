output "alb_name" {
  value = aws_alb.alb.name
}

output "alb_arn" {
  value = aws_alb.alb.arn
}

output "alb_dns_name" {
  value = aws_alb.alb.dns_name
}

output "alb_hosted_zone_id" {
  value = aws_alb.alb.zone_id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "http_listener_arns" {
  value = zipmap(var.http_listener_ports, aws_alb_listener.http.*.arn)
}

data "template_file" "https_listener_acm_certs_ports" {
  count    = length(var.https_listener_ports_and_acm_ssl_certs)
  template = var.https_listener_ports_and_acm_ssl_certs[count.index]["port"]
}

output "https_listener_acm_cert_arns" {
  value = zipmap(
    data.template_file.https_listener_acm_certs_ports.*.rendered,
    aws_alb_listener.https_acm_cert.*.arn
  )
}
