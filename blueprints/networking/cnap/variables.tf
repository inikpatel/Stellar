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
variable "access_policy_number" {
  description = "There can only be one Access Policy per GCP Org. Use gcloud access-context-manager policies list --organization <org-number> to list it."
  type        = number
}

variable "billing_account" {
  description = "GCP Billing Account ID"
  type        = string
}

variable "default_backend" {
  description = "The default backend for traffic at the load-balancer. Must match the key of one of the backends in the data/apps.yaml file"
  type        = string
}

variable "domain" {
  description = "FQDN for the load-balancer hosted apps, where the subdomain will be prepended to"
  type        = string
}

variable "network" {
  description = "Google Compute Network to deploy the Load Balancer on"
  type        = string
}

variable "oauth_brand_number" {
  description = "External Oauth2 consent screens can only be configured via the interactive console. After configuring it, use `gcloud alpha iap oauth-brands list` to lookup the brand id number"
  type        = number
}

variable "organization" {
  description = "GCP Organization is required for Access Context Manager policies which take affect at the org level"
  type        = number
}

variable "prefix" {
  description = "Prefix for naming resources in this blueprint"
  type        = string
  default     = "cnap"
}

variable "project" {
  description = "GCP Project to deploy into"
  type        = string
}

variable "region" {
  description = "GCP Region to deploy into"
  type        = string
}
