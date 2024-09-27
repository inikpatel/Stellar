# These Cloud Run services are meant to represent real applications deployed behind the CNAP
# This isn't mean to imply that *only* Cloud Run applications can be hosted behind the CNAP

resource "google_cloud_run_v2_service" "cloud_run_apps" {
  for_each = local.apps
  name     = "${var.prefix}-${each.key}"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = each.value.cloud_run_image
    }
  }
  binary_authorization {
    use_default = true
  }
}