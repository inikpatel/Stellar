
resource "google_access_context_manager_access_levels" "access-levels" {
  parent = "accessPolicies/${var.access_policy_number}"

  access_levels {
    name  = "accessPolicies/${var.access_policy_number}/accessLevels/USbase"
    title = "US Traffic Source IP"
    basic {
      conditions {
        regions = [
          "US",
        ]
      }
    }
  }

  access_levels {
    name  = "accessPolicies/${var.access_policy_number}/accessLevels/strict_device"
    title = "Strict Device Policy"
    basic {
      conditions {
        device_policy {
          require_screen_lock = true
          os_constraints {
            os_type = "DESKTOP_MAC"
          }
          os_constraints {
            os_type = "DESKTOP_WINDOWS"
          }

          allowed_encryption_statuses = [
            "ENCRYPTED",
          ]
          require_corp_owned = true
        }
        regions = [
          "US",
        ]
      }
    }
  }
}
