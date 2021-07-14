###################################
##### Outputs Route53 Resources ###
###################################

output "domain_name" {
  value = length(aws_route53_record.alias_route_domain) > length(aws_route53_record.cname_route_domain) ? aws_route53_record.alias_route_domain[*].fqdn : aws_route53_record.cname_route_domain[*].fqdn
}
