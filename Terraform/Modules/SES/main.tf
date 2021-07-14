resource "aws_ses_domain_identity" "domain" {
  domain = var.Domain
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = aws_ses_domain_identity.domain.domain
}
