variable "alb_name" {
}

variable "is_internal_alb" {
}

variable "ssl_policy" {
}

variable "vpc_id" {
}

variable "vpc_subnet_ids" {
  type        = list(string)
}

variable "http_listener_ports" {
  description = "A list of ports to listen on for HTTP requests."
  type        = list(number)
  # Example:
  #
  # http_listener_ports = [80]
}

variable "https_listener_ports_and_acm_ssl_certs" {
  description = "A list of objects that define the ports to listen on for HTTPS requests. Each object should have the keys 'port' (the port number to listen on) and 'certificate_domain_name' (the domain/common name of an ACM TLS cert to use on this listener)."
  type = list(object({
    port                    = number
    certificate_domain_name = string
  }))
  # Example:
  # https_listener_ports_and_acm_ssl_certs = [
  #   {
  #     port                    = 443
  #     certificate_domain_name = "*.mydomain.com"
  #   },
  # ]
}

variable "allowed_inbound_cidr_blocks" {
  type        = list(string)
}
