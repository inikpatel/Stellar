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

output "compute-engine-vm-instance" {
  description = "Instance resource."
  sensitive   = true
  value       = try(module.compute-engine-vm.instance)
}

output "compute-engine-vm-instance-id" {
  description = "Fully qualified instance id."
  value       = module.compute-engine-vm.id
}

output "compute-engine-vm-internal_ip" {
  description = "Instance main interface internal IP address."
  value       = module.compute-engine-vm.internal_ip
}

output "compute-engine-vm-internal_ips" {
  description = "Instance interfaces internal IP addresses."
  value       = module.compute-engine-vm.internal_ips
}

output "compute-engine-vm-service_account" {
  description = "Service account resource."
  value       = module.compute-engine-vm.service_account
}

output "compute-engine-vm-service_account_email" {
  description = "Service account email."
  value       = module.compute-engine-vm.service_account_email
}

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

output "nat-id-a" {
  description = "Fully qualified NAT (router) id."
  value       = module.nat-a.id
}

output "nat-id-b" {
  description = "Fully qualified NAT (router) id."
  value       = module.nat-a.id
}

output "nat-name-a" {
  description = "Name of the Cloud NAT."
  value       = module.nat-b.name
}

output "nat-name-b" {
  description = "Name of the Cloud NAT."
  value       = module.nat-b.name
}

output "vpc-network-a" {
  description = "Network resource."
  value       = module.vpc-a.network
}

output "vpc-network-attachment-ids-a" {
  description = "IDs of network attachments."
  value       = module.vpc-a.network_attachment_ids
}

output "vpc-network-attachment-ids-b" {
  description = "IDs of network attachments."
  value       = module.vpc-b.network_attachment_ids
}

output "vpc-network-b" {
  description = "Network resource."
  value       = module.vpc-b.network
}

output "vpc-network-self-link-a" {
  description = "Network self link."
  value       = module.vpc-a.self_link
}

output "vpc-network-self-link-b" {
  description = "Network self link."
  value       = module.vpc-b.self_link
}

output "vpc-subnet-ids-a" {
  description = "Map of subnet IDs keyed by name."
  value       = module.vpc-a.subnet_ids
}

output "vpc-subnet-ids-b" {
  description = "Map of subnet IDs keyed by name."
  value       = module.vpc-b.subnet_ids
}

output "vpc-subnet-ips-a" {
  description = "Map of subnet address ranges keyed by name."
  value       = module.vpc-a.subnet_ips
}

output "vpc-subnet-ips-b" {
  description = "Map of subnet address ranges keyed by name."
  value       = module.vpc-b.subnet_ips
}
