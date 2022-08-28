resource "aws_acm_certificate" "example" {
  domain_name       = "*.perforb.org"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
