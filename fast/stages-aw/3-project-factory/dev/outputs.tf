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

output "projects" {
  description = "Created projects."
  value = {
    for k, v in module.projects.projects : k => {
      number     = v.number
      project_id = v.id
    }
  }
}

output "service_accounts" {
  description = "Created service accounts."
  value       = module.projects.service_accounts
}

output "vpcs-subnets" {
  description = "Created projects."
  value = {
    for k, v in module.vpc : k => {
      vpc_name    = v.name
      project_id  = v.project_id
      subnet_name = v.subnets
    }
  }
}
 