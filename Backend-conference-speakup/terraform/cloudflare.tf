# ============================================================================
# SpeakUp — Cloudflare Configuration
# DNS, WAF, CDN, SSL/TLS, Rate Limiting, Bot Management, DDoS Protection
# ============================================================================

# --------------------------------------------------------------------------
# Data: Cloudflare Zone
# --------------------------------------------------------------------------
data "cloudflare_zone" "main" {
  zone_id = var.cloudflare_zone_id
}

# --------------------------------------------------------------------------
# DNS Records
# --------------------------------------------------------------------------

# API subdomain → EKS load balancer
resource "cloudflare_record" "api" {
  zone_id = var.cloudflare_zone_id
  name    = "api"
  type    = "CNAME"
  content = module.eks.cluster_endpoint
  proxied = true
  ttl     = 1  # Auto when proxied

  comment = "SpeakUp API endpoint"
}

# WebSocket subdomain for real-time meeting communication
resource "cloudflare_record" "ws" {
  zone_id = var.cloudflare_zone_id
  name    = "ws"
  type    = "CNAME"
  content = module.eks.cluster_endpoint
  proxied = true
  ttl     = 1

  comment = "SpeakUp WebSocket endpoint"
}

# Root domain
resource "cloudflare_record" "root" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  type    = "CNAME"
  content = "api.${var.domain_name}"
  proxied = true
  ttl     = 1

  comment = "Root domain redirect"
}

# --------------------------------------------------------------------------
# SSL/TLS Settings
# --------------------------------------------------------------------------
resource "cloudflare_zone_settings_override" "settings" {
  zone_id = var.cloudflare_zone_id

  settings {
    # SSL — Full (Strict) mode
    ssl                      = "strict"
    always_use_https         = "on"
    min_tls_version          = "1.2"
    tls_1_3                  = "on"
    automatic_https_rewrites = "on"

    # Security
    security_level           = "medium"
    browser_check            = "on"
    challenge_ttl            = 1800
    privacy_pass             = "on"
    opportunistic_encryption = "on"

    # Performance
    minify {
      css  = "on"
      js   = "on"
      html = "on"
    }
    brotli     = "on"
    early_hints = "on"
    http3       = "on"

    # Caching
    browser_cache_ttl     = 14400  # 4 hours
    always_online         = "on"
    development_mode      = "off"

    # WebSocket support (critical for real-time meeting communication)
    websockets = "on"

    # Bot management
    security_header {
      enabled            = true
      include_subdomains = true
      max_age            = 31536000
      nosniff            = true
      preload            = true
    }
  }
}

# --------------------------------------------------------------------------
# WAF — Web Application Firewall Rules
# --------------------------------------------------------------------------

# Block known bad bots and scrapers
resource "cloudflare_ruleset" "waf_custom" {
  zone_id     = var.cloudflare_zone_id
  name        = "SpeakUp WAF Rules"
  description = "Custom WAF rules for video conferencing API protection"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  # Block requests without User-Agent
  rules {
    action      = "block"
    expression  = "not http.user_agent ne \"\""
    description = "Block requests without User-Agent"
    enabled     = true
  }

  # Block SQL injection attempts
  rules {
    action      = "block"
    expression  = "http.request.uri.query contains \"UNION\" or http.request.uri.query contains \"SELECT\" or http.request.uri.query contains \"DROP\""
    description = "Block SQL injection in query params"
    enabled     = true
  }

  # Rate limit auth endpoints (stricter)
  rules {
    action      = "block"
    expression  = "http.request.uri.path contains \"/api/v1/auth\" and rate(cf.colo.id, 1m) > 10"
    description = "Rate limit authentication endpoints"
    enabled     = true
  }

  # Challenge suspicious billing requests
  rules {
    action      = "managed_challenge"
    expression  = "http.request.uri.path contains \"/api/v1/billing\" and not cf.bot_management.verified_bot"
    description = "Challenge unverified bots on billing endpoints"
    enabled     = true
  }

  # Protect admin routes
  rules {
    action      = "managed_challenge"
    expression  = "http.request.uri.path contains \"/api/v1/admin\""
    description = "Challenge all admin endpoint requests"
    enabled     = true
  }
}

# --------------------------------------------------------------------------
# Rate Limiting Rules
# --------------------------------------------------------------------------
resource "cloudflare_ruleset" "rate_limiting" {
  zone_id     = var.cloudflare_zone_id
  name        = "SpeakUp Rate Limiting"
  description = "Rate limiting rules for API endpoints"
  kind        = "zone"
  phase       = "http_ratelimit"

  # General API rate limit: 100 requests per minute
  rules {
    action = "block"
    ratelimit {
      characteristics     = ["cf.colo.id", "ip.src"]
      period              = 60
      requests_per_period = 100
      mitigation_timeout  = 60
    }
    expression  = "http.request.uri.path matches \"^/api/\""
    description = "General API rate limit"
    enabled     = true
  }

  # Auth rate limit: 10 requests per minute
  rules {
    action = "block"
    ratelimit {
      characteristics     = ["cf.colo.id", "ip.src"]
      period              = 60
      requests_per_period = 10
      mitigation_timeout  = 300
    }
    expression  = "http.request.uri.path matches \"^/api/v1/auth\""
    description = "Auth endpoint rate limit"
    enabled     = true
  }

  # Billing rate limit: 5 requests per minute
  rules {
    action = "block"
    ratelimit {
      characteristics     = ["cf.colo.id", "ip.src"]
      period              = 60
      requests_per_period = 5
      mitigation_timeout  = 600
    }
    expression  = "http.request.uri.path matches \"^/api/v1/billing\""
    description = "Billing endpoint rate limit"
    enabled     = true
  }

  # Chat rate limit: 120 requests per minute (high-frequency messaging)
  rules {
    action = "block"
    ratelimit {
      characteristics     = ["cf.colo.id", "ip.src"]
      period              = 60
      requests_per_period = 120
      mitigation_timeout  = 30
    }
    expression  = "http.request.uri.path matches \"^/api/v1/chat\""
    description = "Chat endpoint rate limit"
    enabled     = true
  }
}

# --------------------------------------------------------------------------
# Cache Rules — API responses that can be cached
# --------------------------------------------------------------------------
resource "cloudflare_ruleset" "cache_rules" {
  zone_id     = var.cloudflare_zone_id
  name        = "SpeakUp Cache Rules"
  description = "Caching rules for static and semi-static content"
  kind        = "zone"
  phase       = "http_request_cache_settings"

  # Cache health check endpoint
  rules {
    action = "set_cache_settings"
    action_parameters {
      cache = true
      edge_ttl {
        mode    = "override_origin"
        default = 30
      }
      browser_ttl {
        mode    = "override_origin"
        default = 10
      }
    }
    expression  = "http.request.uri.path eq \"/health\""
    description = "Cache health check"
    enabled     = true
  }

  # Cache app settings (rarely change)
  rules {
    action = "set_cache_settings"
    action_parameters {
      cache = true
      edge_ttl {
        mode    = "override_origin"
        default = 3600
      }
      browser_ttl {
        mode    = "override_origin"
        default = 1800
      }
    }
    expression  = "http.request.uri.path matches \"^/api/v1/settings\""
    description = "Cache app settings"
    enabled     = true
  }

  # Never cache auth, meetings, billing, or chat
  rules {
    action = "set_cache_settings"
    action_parameters {
      cache = false
    }
    expression  = "http.request.uri.path matches \"^/api/v1/(auth|meetings|billing|chat)\""
    description = "Bypass cache for dynamic endpoints"
    enabled     = true
  }
}

# --------------------------------------------------------------------------
# Page Rules — Redirects and overrides
# --------------------------------------------------------------------------
resource "cloudflare_page_rule" "api_ssl" {
  zone_id  = var.cloudflare_zone_id
  target   = "http://api.${var.domain_name}/*"
  priority = 1

  actions {
    always_use_https = true
  }
}

resource "cloudflare_page_rule" "ws_ssl" {
  zone_id  = var.cloudflare_zone_id
  target   = "http://ws.${var.domain_name}/*"
  priority = 2

  actions {
    always_use_https = true
  }
}

# --------------------------------------------------------------------------
# Firewall — Geo-blocking (optional, restrict to operational regions)
# --------------------------------------------------------------------------
resource "cloudflare_ruleset" "geo_blocking" {
  zone_id     = var.cloudflare_zone_id
  name        = "SpeakUp Geo Rules"
  description = "Geographic access restrictions"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  # Allow only specific countries (customize for your operational regions)
  # Uncomment and modify as needed:
  # rules {
  #   action      = "block"
  #   expression  = "not ip.geoip.country in {\"NG\" \"US\" \"GB\" \"GH\" \"KE\" \"ZA\"}"
  #   description = "Block traffic from non-operational regions"
  #   enabled     = false
  # }

  # Always allow health check endpoints
  rules {
    action      = "skip"
    action_parameters {
      ruleset = "current"
    }
    expression  = "http.request.uri.path eq \"/health\""
    description = "Allow health checks from anywhere"
    enabled     = true
    logging {
      enabled = true
    }
  }
}