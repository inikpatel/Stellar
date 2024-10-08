/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# tfdoc:file:description Lightweight tenant resources.

# TODO(ludo): add support for CI/CD

locals {
  tenant_iam = {
    for k, v in var.tenants : k => [
      v.admin_principal,
      module.tenant-self-iac-sa[k].iam_email
    ]
  }
  gcs_locations = { for k, v in var.tenants : k => try(v.locations.gcs != "", false) ? v.locations.gcs : var.locations.gcs }
}

# top-level "Tenants" folder

module "tenant-tenants-folder" {
  source = "../../../modules/folder"
  parent = var.assured_workloads.folder
  name   = "Tenants"
  iam    = var.folder_iam.tenants
  tag_bindings = {
    context = module.organization.tag_values["${var.tag_names.context}/tenant"].id
  }
}

# Tenant folders (top, core, self)
module "tenant-top-folder" {
  source   = "../../../modules/folder"
  for_each = var.tenants
  parent   = module.tenant-tenants-folder.id
  name     = try(each.value.compliance.regime != "", false) ? lower(replace("${each.value.descriptive_name}-${each.value.compliance.regime}", "_", "-")) : lower(each.value.descriptive_name)
  iam_by_principals = {
    (each.value.admin_principal) = ["roles/browser"]
  }
}

module "tenant-top-folder-iam" {
  source        = "../../../modules/folder"
  for_each      = var.tenants
  id            = module.tenant-top-folder[each.key].id
  folder_create = false
  tag_bindings = {
    tenant = module.organization.tag_values["${var.tag_names.tenant}/${each.key}"].id
  }
  iam = merge(
    {
      "roles/cloudasset.owner"               = [module.tenant-core-sa[each.key].iam_email]
      "roles/compute.xpnAdmin"               = [module.tenant-core-sa[each.key].iam_email]
      "roles/logging.admin"                  = [module.tenant-core-sa[each.key].iam_email]
      "roles/resourcemanager.folderAdmin"    = [module.tenant-core-sa[each.key].iam_email]
      "roles/resourcemanager.projectCreator" = [module.tenant-core-sa[each.key].iam_email]
      "roles/resourcemanager.tagUser"        = [module.tenant-core-sa[each.key].iam_email]
    },
    {
      for k in var.tenants_config.top_folder_roles :
      k => local.tenant_iam[each.key]
    }
  )
}

module "tenant-core-folder" {
  source   = "../../../modules/folder"
  for_each = var.tenants
  parent   = module.tenant-top-folder[each.key].id
  name     = "${each.value.descriptive_name} - Core"
}

module "tenant-core-folder-iam" {
  source        = "../../../modules/folder"
  for_each      = var.tenants
  id            = module.tenant-core-folder[each.key].id
  folder_create = false
  iam = merge(
    {
      "roles/owner" = [
        module.tenant-core-sa[each.key].iam_email
      ]
      "roles/viewer" = local.tenant_iam[each.key]
    },
    {
      for k in var.tenants_config.core_folder_roles :
      k => local.tenant_iam[each.key]
    }
  )
}

module "tenant-self-folder" {
  source   = "../../../modules/folder"
  for_each = var.tenants
  parent   = module.tenant-top-folder[each.key].id
  name     = "${each.value.descriptive_name} - Tenant"
}

module "tenant-self-folder-iam" {
  source        = "../../../modules/folder"
  for_each      = var.tenants
  id            = module.tenant-self-folder[each.key].id
  folder_create = false
  iam = merge(
    {
      "roles/cloudasset.owner"               = local.tenant_iam[each.key]
      "roles/compute.xpnAdmin"               = local.tenant_iam[each.key]
      "roles/resourcemanager.folderAdmin"    = local.tenant_iam[each.key]
      "roles/resourcemanager.projectCreator" = local.tenant_iam[each.key]
      "roles/resourcemanager.tagUser"        = local.tenant_iam[each.key]
      "roles/owner"                          = local.tenant_iam[each.key]
    },
    {
      for k in var.tenants_config.tenant_folder_roles :
      k => local.tenant_iam[each.key]
    }
  )
}

# Tenant IaC resources (core)

module "tenant-core-sa" {
  source      = "../../../modules/iam-service-account"
  for_each    = var.tenants
  project_id  = var.automation.project_id
  name        = "tn-${each.key}-0"
  description = "Terraform service account for tenant ${each.key}."
  prefix      = var.prefix
  iam_project_roles = {
    (var.automation.project_id) = ["roles/serviceusage.serviceUsageConsumer"]
  }
}

module "tenant-core-gcs" {
  source     = "../../../modules/gcs"
  for_each   = var.tenants
  project_id = var.automation.project_id
  name       = "tn-${each.key}-0"
  prefix     = var.prefix
  versioning = true
  location   = local.gcs_locations[each.key]
  storage_class = (
    length(split("-", local.gcs_locations[each.key])) < 2
    ? "MULTI_REGIONAL"
    : "REGIONAL"
  )
  # encryption_key = module.tenant-project-key[each.key].key_ids["gcs"]
  depends_on = [module.tenant-project-key]
  iam = {
    "roles/storage.objectAdmin" = [module.tenant-core-sa[each.key].iam_email]
  }
}

# Tenant IaC project and resources (self)
module "tenant-self-iac-project" {
  source   = "../../../modules/project"
  for_each = var.tenants
  billing_account = (
    each.value.billing_account != null
    ? each.value.billing_account
    : var.billing_account.id
  )
  name   = "${each.key}-iac-core-0"
  parent = module.tenant-core-folder[each.key].id
  prefix = var.prefix
  iam_by_principals = {
    (each.value.admin_principal) = [
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountTokenCreator",
      "roles/iam.workloadIdentityPoolAdmin"
    ]
  }
  iam = {
    (var.custom_roles.storage_viewer) = [
      "serviceAccount:${var.automation.service_accounts.resman-r}"
    ]
    "roles/viewer" = [
      "serviceAccount:${var.automation.service_accounts.resman-r}"
    ]
  }
  services = [
    "accesscontextmanager.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryreservation.googleapis.com",
    "bigquerystorage.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "essentialcontacts.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "orgpolicy.googleapis.com",
    "pubsub.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-component.googleapis.com",
    "storage.googleapis.com",
    "sts.googleapis.com"
  ]
}

module "tenant-self-iac-gcs-outputs" {
  source     = "../../../modules/gcs"
  for_each   = var.tenants
  project_id = module.tenant-self-iac-project[each.key].project_id
  location   = local.gcs_locations[each.key]
  storage_class = (
    length(split("-", local.gcs_locations[each.key])) < 2
    ? "MULTI_REGIONAL"
    : "REGIONAL"
  )
  name       = "${each.key}-iac-outputs-0"
  prefix     = var.prefix
  versioning = true
  iam = {
    "roles/storage.objectAdmin" = [module.tenant-core-sa[each.key].iam_email]
  }
  encryption_key = module.tenant-project-key[each.key].key_ids["gcs"]
  depends_on     = [module.tenant-project-key]

}

module "tenant-project-key" {
  source     = "../../../modules/kms"
  project_id = module.tenant-self-iac-project[each.key].project_id
  for_each   = var.tenants
  iam = {
    "roles/cloudkms.cryptoKeyEncrypterDecrypter" = [
      module.tenant-core-sa[each.key].iam_email,
      "serviceAccount:service-${module.tenant-self-iac-project[each.key].number}@gs-project-accounts.iam.gserviceaccount.com"
    ]
  }
  keyring = {
    name     = "${each.key}-keyring"
    location = try(each.value.locations.kms != "", false) ? each.value.locations.kms : var.locations.kms
  }
  keys = {
    gcs = {
      purpose         = "ENCRYPT_DECRYPT"
      labels          = { service = "gcs" }
      locations       = try(each.value.locations.kms != "", false) ? each.value.locations.kms : var.locations.kms
      rotation_period = "7776000s"
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "HSM"
      }
    }
  }
}

module "tenant-self-iac-gcs-state" {
  source     = "../../../modules/gcs"
  for_each   = var.tenants
  project_id = module.tenant-self-iac-project[each.key].project_id
  location   = local.gcs_locations[each.key]
  storage_class = (
    length(split("-", local.gcs_locations[each.key])) < 2
    ? "MULTI_REGIONAL"
    : "REGIONAL"
  )
  name           = "${each.key}-iac-0"
  prefix         = var.prefix
  versioning     = true
  encryption_key = module.tenant-project-key[each.key].key_ids["gcs"]
  depends_on     = [module.tenant-project-key]
}

module "tenant-self-iac-sa" {
  source      = "../../../modules/iam-service-account"
  for_each    = var.tenants
  project_id  = module.tenant-self-iac-project[each.key].project_id
  name        = "${each.key}-iac-0"
  description = "Terraform automation service account."
  prefix      = var.prefix
  iam_storage_roles = {
    (module.tenant-self-iac-gcs-outputs[each.key].name) = [
      "roles/storage.admin"
    ]
    (module.tenant-self-iac-gcs-state[each.key].name) = [
      "roles/storage.admin"
    ]
  }
}

