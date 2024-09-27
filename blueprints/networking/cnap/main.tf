locals {
  apps = yamldecode(templatefile("./data/cloudrun.yaml", {
    DOMAIN       = var.domain,
    ACCESSPOLICY = var.access_policy_number
  }))
}

data "google_project" "project" {
  project_id = var.project
}

resource "google_project_service" "services" {
  for_each = toset([
    "accesscontextmanager.googleapis.com",
    "beyondcorp.googleapis.com",
    "binaryauthorization.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "orgpolicy.googleapis.com",
    "run.googleapis.com",
    "serviceusage.googleapis.com"
  ])
  service = each.value
  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = false

}