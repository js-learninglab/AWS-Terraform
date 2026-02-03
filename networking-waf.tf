### this .tf is to create a WAF and associate it to my ALB in frontend vpc
# i have 2 ALBs. 1 is a web sg and another is asg sg.check

resource "aws_wafv2_web_acl" "a_web_lb_waf" {
  name        = "${local.naming_prefix}-${var.environment}-web-lb-waf"
  description = "WAF for web load balancer"
  scope       = "REGIONAL" # CLOUDFRONT = global, REGIONAL = ALB, API Gateway, etc.
  default_action {
    allow {}
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 2
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
    }
  }

  rule {
    name     = "RateLimitRule"
    priority = 1
    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = 100 # limiting to 100 requests in 5 minute period
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.naming_prefix}-waf-web-acl"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "GeoBlockingRule"
    priority = 0
    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = ["KP", "CN", "RU"] # example country codes to block ; North Korea, China, Russia
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "GeoBlockingRule"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-web-lb-waf" })
}

# now that i hav waf, i need to associate it to my ALB in frontend vpc
resource "aws_wafv2_web_acl_association" "a_web_lb_waf_assoc" {
  resource_arn = aws_lb.a_web_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.a_web_lb_waf.arn
}

resource "aws_wafv2_web_acl_association" "a_web_lb_asg_waf_assoc" {
  resource_arn = aws_lb.asg_web_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.a_web_lb_waf.arn
}