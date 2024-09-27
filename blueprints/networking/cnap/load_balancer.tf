locals {
  backends = { for key, _ in local.apps : key =>
    {
      backends = [
        { backend = "neg-${key}" }
      ]
      health_checks = []
      port_name     = ""
      iap_config = {
        oauth2_client_id     = google_iap_client.project_client.client_id
        oauth2_client_secret = google_iap_client.project_client.secret
      }
    }
  }

  host_rules = [for key, values in local.apps : {
    hosts        = ["${values.subdomain}.${var.domain}"],
    path_matcher = "path-matcher-${key}"
  }]
  lb_name       = "${var.prefix}-cloud-native-access-point"
  service_names = { for app, _ in local.apps : app => "https://www.googleapis.com/compute/v1/projects/${var.project}/regions/${var.region}/backendServices/${local.lb_name}-${app}" }

}
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "default" {
  private_key_pem = tls_private_key.default.private_key_pem
  subject {
    common_name  = var.domain
    organization = "ACME Examples, Inc"
  }
  dns_names             = [for app, _ in local.apps : "${app}.${var.domain}"]
  validity_period_hours = 720
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "google_compute_address" "cnap-ext-ip" {
  name         = "cnap-ip"
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}


module "cnap-0-redirect" {
  source     = "../../../modules/net-lb-app-ext-regional/"
  project_id = var.project
  name       = "${var.prefix}-cloud-native-access-point-redirect"
  vpc        = var.network
  region     = var.region
  address = (
    google_compute_address.cnap-ext-ip.id
  )
  health_check_configs = {}
  urlmap_config = {
    description = "URL redirect for ${var.prefix}-cloud-native-access-point."
    default_url_redirect = {
      https         = true
      response_code = "MOVED_PERMANENTLY_DEFAULT"
    }
  }
  depends_on = [google_org_policy_policy.allow_external_lb]
}

module "cnap-0" {
  source     = "../../../modules/net-lb-app-ext-regional/"
  project_id = var.project
  name       = local.lb_name
  vpc        = var.network
  region     = var.region
  address = (
    google_compute_address.cnap-ext-ip.id
  )
  backend_service_configs = local.backends
  # with a single serverless NEG the implied default health check is not needed
  health_check_configs = {}
  neg_configs = { for key, _ in local.apps : "neg-${key}" =>
    {
      project = var.project
      cloudrun = {
        region = var.region
        target_service = {
          name = google_cloud_run_v2_service.cloud_run_apps[key].name
        }
      }
  } }

  urlmap_config = {
    default_service = local.service_names[var.default_backend]
    host_rules      = local.host_rules
    path_matchers = { for app, values in local.apps : "path-matcher-${app}" => {
      paths           = ["/*"],
      default_service = local.service_names[app]
      }
    }

  }
  protocol = "HTTPS"
  ssl_certificates = {
    create_configs = {
      default = {
        # certificate and key could also be read via file() from external files
        certificate = tls_self_signed_cert.default.cert_pem
        private_key = tls_private_key.default.private_key_pem
      }
    }
  }

  depends_on = [google_cloud_run_v2_service.cloud_run_apps, google_org_policy_policy.allow_external_lb]
}
