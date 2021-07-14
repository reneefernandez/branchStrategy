#****************************
#***  Route53 Resources *****
#****************************

#---------- Route53 Creation Records ----------

# resource "aws_route53_zone" "route_zone" {
#   name = "client.dev."
# }

# creates an A record domain
resource "aws_route53_record" "alias_route_domain" {
  count = var.Record_Type == "A" ? 1 : 0
  zone_id = var.HostedZoneId
  name = var.Custom_Domain
  type = var.Record_Type
  alias {
    name = var.Alias_Name
    zone_id = var.Alias_Hosted_Zone
    evaluate_target_health = false
  }
}

# creates an CName record domain
resource "aws_route53_record" "cname_route_domain" {
  count = var.Record_Type == "CNAME" ? 1 : 0
  zone_id = var.HostedZoneId
  name = var.Custom_Domain
  type = var.Record_Type
  ttl     = var.CName_TTL
  records = [var.CName]
}