# Cloud Native Access Point

This blueprint bootstraps a minimal environment using the concepts for a Cloud Native Access Point and BeyondCorp. For more information about the CNAP, please see the [Department of Defence Cloud Native Access Point Reference Design](https://dodcio.defense.gov/Portals/0/Documents/Library/CNAP_RefDesign_v1.0.pdf).

## Description

This is an implementation of the CNAP Reference Design using the native Zero Trust functionality of Google Cloud.

This is by no means complete, and we expect to add more functionality to this blueprint as we build out our CNAP solution. For example, it currently only deploys demo apps to Cloud Run. It is intended to

Features to be developed:
- [ ] Cloud Armor WAF policies
- [ ] Cloud IDS

## Prerequisites

Before running `terraform apply` some setup is required in the environment

### 1. Gcloud Authentication Configuration

Make sure your gcloud cli is authenticated and configured for the correct project `gcloud auth login`, `gcloud config set project <project-id>`, `gcloud auth application-default login`, and `gcloud auth application-default set-quota-project <project-id>`

### 2. Enable APIs

Before you can run `terraform apply`, you must enable some basic APIs.


Run `for api in  "serviceusage" "compute" "accesscontextmanager" "cloudresourcemanager" "orgpolicy"; do  gcloud services enable $api.googleapis.com; done`

We recommend waiting about 10 minutes for this change to propogate within the system.

### 3. Access Policies

Access policies are defined at the organization level, and there can only be one declared per organization. Each one can have multiple access levels within it. In order to correctly associate the access levels created in the blueprint with your organizions access policy, we need to populate that variable in the `.tfvars` file.

To list the access policies in your org, run `gcloud access-context-manager policies list --organization <org-id>` and find the `NAME:` of the access policy associated with the org.

If this is a completely new org and you need to create an access policy, you may use `gcloud access-context-manager policies create --organization <org-id> --title CNAP-policy`, and use the number returned after creation.

### 4. Oauth2 Consent Screen

Configure an Oauth2 Consent screen for your project here https://console.cloud.google.com/apis/credentials/consent

It doesn't matter if it's external or internal, so do whatever meets your system requirements. Internal is better for testing.
For test setup, just use all the defaults and don't assign any extra scopes.

Once it's created, run `gcloud alpha iap oauth-brands list` to look up the number and add the value to `.tfvars`

### 5. Proxy Only Subnet

Your VPC network must have a dedicated "Proxy Only" subnet configured for "Regional Managed Proxy".
Your VPC may already have a dedicated "Proxy Only" subnet in your region, but if it does not you will need to deploy one.

The command to create a new "Proxy Only" subnet is as follows:
```
gcloud compute networks subnets create vpc-proxies \
    --purpose=REGIONAL_MANAGED_PROXY \
    --role=ACTIVE \
    --region=<us-region> \
    --network=<vpc-network> \
    --range=10.40.2.0/24
```
Note: You will need to adjust the subnet range to be outside of any other allocated ranges within the VPC. If the subnet range listed above does not work, you will need to find a usable /24 range, which is outside the scope of this guide.

### 6. DNS

To make this blueprint work, you will need to create a wildcard DNS entry for your domain pointing to your Regional Load Balancer front-end. Oftentimes the DNS control will be outside of the project, and exact instructions very between providers. Work with whoever manages your DNS entries to make the appropriate changes once the load balancer is deployed.

## Configuration

There are two sources of configuration for this blueprint: The `cloudrun.yaml` file in the `data/` folder, as well as normal `.tfvars`. In the `.tfvars` file, there are parameters that define this deployment, such as organization information and domains. In the cloudrun.yaml, we define the Cloud Run applications that will be created, as well as the IAM configuration for how these will be protected behind the IAP.

In the `cloudrun.yaml` file, certain variables are templated in using the standard Terraform templating language, Jinja2.

| Variable in template | Value Source | Description |
|----|----|----|
| DOMAIN | var.domain, from the `.tfvars` file | The domain for the application, here used for templating out groups. Groups in the IAM policy must be valid at the time of apply | google_access_context_manager_access_policy.access-policy.id | This policy ID is required to form the name of the access levels for creating IAM rules, but the specific value is not known until the resource is created. |
## Deploying the Blueprint

Because deploying this blueprint may require updating your org policy to allow external load balancers, you must use a `-target` apply to make sure that change is made first, then the rest of the application will deploy.

Run `terraform apply -target google_org_policy_policy.allow_external_lb` after configuring the `cloudrun.yaml` and `terraform.tfvars` files appropriately. This setting may take a few minutes to work after the `terraform apply` completes.


<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [access_policy_number](variables.tf#L16) | There can only be one Access Policy per GCP Org. Use gcloud access-context-manager policies list --organization <org-number> to list it. | <code>number</code> | ✓ |  |
| [billing_account](variables.tf#L21) | GCP Billing Account ID | <code>string</code> | ✓ |  |
| [default_backend](variables.tf#L26) | The default backend for traffic at the load-balancer. Must match the key of one of the backends in the data/apps.yaml file | <code>string</code> | ✓ |  |
| [domain](variables.tf#L31) | FQDN for the load-balancer hosted apps, where the subdomain will be prepended to | <code>string</code> | ✓ |  |
| [network](variables.tf#L36) | Google Compute Network to deploy the Load Balancer on | <code>string</code> | ✓ |  |
| [oauth_brand_number](variables.tf#L41) | External Oauth2 consent screens can only be configured via the interactive console. After configuring it, use `gcloud alpha iap oauth-brands list` to lookup the brand id number | <code>number</code> | ✓ |  |
| [organization](variables.tf#L46) | GCP Organization is required for Access Context Manager policies which take affect at the org level | <code>number</code> | ✓ |  |
| [project](variables.tf#L57) | GCP Project to deploy into | <code>string</code> | ✓ |  |
| [region](variables.tf#L62) | GCP Region to deploy into | <code>string</code> | ✓ |  |
| [prefix](variables.tf#L51) | Prefix for naming resources in this blueprint | <code>string</code> |  | <code>&#34;cnap&#34;</code> |
<!-- END TFDOC -->
