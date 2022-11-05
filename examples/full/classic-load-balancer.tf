module "classic_load_balancer" {
  source = "../../"

  vpc_id     = module.base_network.vpc_id
  subnet_ids = module.base_network.public_subnet_ids

  domain_name = var.domain_name
  public_zone_id = var.public_zone_id
  private_zone_id = var.private_zone_id

  component = var.component
  deployment_identifier = var.deployment_identifier

  egress_cidrs = ["10.0.0.0/8"]

  listeners = [
    {
      lb_port = 80
      lb_protocol = "HTTP"
      instance_port = 80
      instance_protocol = "HTTP"
      ssl_certificate_id = ""
    },
    {
      lb_port = 6567
      lb_protocol = "SSL"
      instance_port = 6567
      instance_protocol = "SSL"
      ssl_certificate_id = module.acm_certificate.certificate_arn
    }
  ]
  access_control = [
    {
      lb_port = 80
      instance_port = 80
      allow_cidrs = ["0.0.0.0/0"]
    },
    {
      lb_port = 6567
      instance_port = 6567
      allow_cidrs = ["10.0.0.0/8"]
    }
  ]

  enable_connection_draining = "yes"

  include_public_dns_record = "yes"
  expose_to_public_internet = "yes"
}
