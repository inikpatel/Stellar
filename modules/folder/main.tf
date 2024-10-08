
/**
 * Copyright 2023 Google LLC
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

locals {
  folder_id = (
    var.folder_create
    ? try(google_folder.folder[0].id, null)
    : var.id
  )
}

resource "google_folder" "folder" {
  count        = var.folder_create ? 1 : 0
  display_name = var.name
  parent       = var.parent
}

resource "google_essential_contacts_contact" "contact" {
  provider                            = google-beta
  for_each                            = var.contacts
  parent                              = local.folder_id
  email                               = each.key
  language_tag                        = "en"
  notification_category_subscriptions = each.value
  depends_on = [
    google_folder_iam_binding.authoritative,
    google_folder_iam_binding.bindings,
    google_folder_iam_member.bindings
  ]
}

resource "google_compute_firewall_policy_association" "default" {
  count             = var.firewall_policy == null ? 0 : 1
  attachment_target = local.folder_id
  name              = var.firewall_policy.name
  firewall_policy   = var.firewall_policy.policy
}
