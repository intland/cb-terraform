data "aws_route53_zone" "public" {
  name = var.top_domain
}

resource "aws_route53_record" "public" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.client_url
  type    = "A"
  ttl     = "60" 
  records = [aws_eip.cb.public_ip]
}