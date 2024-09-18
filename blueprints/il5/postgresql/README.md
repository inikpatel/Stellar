Copyright 2023 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Requirements
1. An existing VPC
1. Copy terraform.tfvars.sample to terraform.tfvars
1. Updated terraform.tfvars

## Notes
1. There seems to be a provider bug that will not allow a full terraform delete to complete due to the following error:

```
Unable to remove Service Networking Connection, err: Error waiting for Delete Service Networking Connection: Error code 9, message: Failed to delete connection; Producer services (e.g. CloudSQL, Cloud Memstore, etc.) are still using this connection.
```

To ensure proper deletion, please manually delete the peered network that is created, release the allocated ip address, and remove the following three services from the terraform state (terraform state rm <service-name>)
```
data.google_compute_network.network
google_compute_global_address.postgres
google_service_networking_connection.postgres
```
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [database_name](variables.tf#L29) | This is the name of the database. | <code>string</code> | ✓ |  |
| [firewall_name](variables.tf#L59) | Firewall name. | <code>string</code> | ✓ |  |
| [firewall_source_range](variables.tf#L64) | Firewall source IP range. | <code>list&#40;any&#41;</code> | ✓ |  |
| [keyring](variables.tf#L75) | Keyring attributes. | <code title="object&#40;&#123;&#10;  location &#61; string&#10;  name     &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> | ✓ |  |
| [keys](variables.tf#L83) | Key names and base attributes. Set attributes to null if not needed. | <code title="map&#40;object&#40;&#123;&#10;  destroy_scheduled_duration    &#61; optional&#40;string&#41;&#10;  rotation_period               &#61; optional&#40;string&#41;&#10;  labels                        &#61; optional&#40;map&#40;string&#41;&#41;&#10;  purpose                       &#61; optional&#40;string, &#34;ENCRYPT_DECRYPT&#34;&#41;&#10;  skip_initial_version_creation &#61; optional&#40;bool, false&#41;&#10;  version_template &#61; optional&#40;object&#40;&#123;&#10;    algorithm        &#61; string&#10;    protection_level &#61; optional&#40;string, &#34;HSM&#34;&#41;&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  iam &#61; optional&#40;map&#40;list&#40;string&#41;&#41;, &#123;&#125;&#41;&#10;  iam_bindings &#61; optional&#40;map&#40;object&#40;&#123;&#10;    members &#61; list&#40;string&#41;&#10;    role    &#61; string&#10;    condition &#61; optional&#40;object&#40;&#123;&#10;      expression  &#61; string&#10;      title       &#61; string&#10;      description &#61; optional&#40;string&#41;&#10;    &#125;&#41;&#41;&#10;  &#125;&#41;&#41;, &#123;&#125;&#41;&#10;  iam_bindings_additive &#61; optional&#40;map&#40;object&#40;&#123;&#10;    member &#61; string&#10;    role   &#61; string&#10;    condition &#61; optional&#40;object&#40;&#123;&#10;      expression  &#61; string&#10;      title       &#61; string&#10;      description &#61; optional&#40;string&#41;&#10;    &#125;&#41;&#41;&#10;  &#125;&#41;&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> | ✓ |  |
| [network_name](variables.tf#L206) | This is the name of the network. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L211) | This is the project ID. Please set using a terraform.tfvars file. | <code>string</code> | ✓ |  |
| [allowed_firewall_ports](variables.tf#L17) | Allowed firewall ports. Postgresql used 5432. | <code>list&#40;number&#41;</code> |  | <code>&#91;5432&#93;</code> |
| [database_instance_tier](variables.tf#L23) | This specifies the kind of machine-type that we will be running it from. | <code>string</code> |  | <code>&#34;db-g1-small&#34;</code> |
| [database_version](variables.tf#L34) | This is the database type that we are running the cloud sql instance. | <code>string</code> |  | <code>&#34;POSTGRES_13&#34;</code> |
| [deletion_protection](variables.tf#L40) | Terraform deletion protection. | <code>bool</code> |  | <code>true</code> |
| [enable_pgaudit](variables.tf#L46) | This extension provides detailed session and object logging to comply with government, financial & ISO standards and provides auditing capabilities to mitigate threats by monitoring security events on the instance. | <code>string</code> |  | <code>&#34;On&#34;</code> |
| [google_compute_global_address_name](variables.tf#L69) | Global address for VPC name. | <code>string</code> |  | <code>&#34;postgres&#34;</code> |
| [log_connections](variables.tf#L118) | Enabling the log_connections setting causes each attempted connection to the server to be logged, along with successful completion of client authentication. | <code>string</code> |  | <code>&#34;on&#34;</code> |
| [log_disconnections](variables.tf#L131) | Enabling the log_disconnections setting logs the end of each session, including the session duration. | <code>string</code> |  | <code>&#34;on&#34;</code> |
| [log_error_verbosity](variables.tf#L144) | The log_error_verbosity flag controls the verbosity/details of messages logged. | <code>string</code> |  | <code>&#34;DEFAULT&#34;</code> |
| [log_min_duration_statement](variables.tf#L157) | Type the minimum amount of execution time of a statement in milliseconds where the total duration of the statement is logged or \"-1\" to disable. | <code>number</code> |  | <code>-1</code> |
| [log_min_error_statement](variables.tf#L169) | The log_min_error_statement flag defines the minimum message severity level that are considered as an error statement. | <code>string</code> |  | <code>&#34;ERROR&#34; &#35; Required for CIS Compliance Benchmark 6.2&#34;</code> |
| [log_min_messages](variables.tf#L180) | The log_min_messages flag defines the minimum message severity level that is considered as an error statement. | <code>string</code> |  | <code>&#34;WARNING&#34;</code> |
| [log_statement](variables.tf#L193) | The value of log_statement flag determines the SQL statements that are logged. | <code>string</code> |  | <code>&#34;ddl&#34;</code> |
| [region](variables.tf#L216) | This is the region that we are going to be running the cloud sql instance from. | <code>string</code> |  | <code>&#34;us-east4&#34;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [connection_internal_ip](outputs.tf#L17) | Conntection internal IP address. |  |
<!-- END TFDOC -->
