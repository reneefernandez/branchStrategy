# # # # # # # # # # # # # # # # # #
# # #   Providers - Section   # # #
# # # # # # # # # # # # # # # # # #

#### Production account
provider "aws" {
  alias   = "prod-account"
  profile = "production"
  region  = "${var.Region}"
}

resource "aws_route53_record" "domain_amazonses_verification_record" {
  provider = aws.prod-account
  count   = var.HostedZoneId != null ? 1 : 0
  zone_id = var.HostedZoneId
  name    = "_amazonses.${var.Domain}"
  type    = "TXT"
  ttl     = "3600"
  records = concat([aws_ses_domain_identity.domain.verification_token], var.SES_records)
}

resource "aws_route53_record" "domain_amazonses_dkim_record" {
  provider = aws.prod-account
  count   = var.HostedZoneId != null ? 3 : 0
  zone_id = var.HostedZoneId
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${var.Domain}"
  type    = "CNAME"
  ttl     = "3600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
