/**
 * Copyright 2022 Google LLC
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

output "keyring-id" {
  description = "Fully qualified keyring id."
  value       = module.kms.id
}

output "keyring-location" {
  description = "Keyring location."
  value       = module.kms.location
}

output "keyring-name" {
  description = "Keyring name."
  value       = module.kms.name
}

output "keyring-resource" {
  description = "Keyring resource."
  value       = module.kms.keyring
}

output "keyrings-keys" {
  description = "Key resources."
  value       = module.kms.keys
}

output "shielded-vm-instance" {
  description = "Instance resource."
  sensitive   = true
  value       = try(module.shielded-vm.instance)
}

output "shielded-vm-instance-id" {
  description = "Fully qualified instance id."
  value       = module.shielded-vm.id
}

output "shielded-vm-internal_ip" {
  description = "Instance main interface internal IP address."
  value       = module.shielded-vm.internal_ip
}

output "shielded-vm-internal_ips" {
  description = "Instance interfaces internal IP addresses."
  value       = module.shielded-vm.internal_ips
}

output "shielded-vm-service_account" {
  description = "Service account resource."
  value       = module.shielded-vm.service_account
}

output "shielded-vm-service_account_email" {
  description = "Service account email."
  value       = module.shielded-vm.service_account_email
}
