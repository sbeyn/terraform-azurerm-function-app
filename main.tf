data "azurerm_client_config" "main" {}

resource "random_string" "main" {
  length  = 8
  lower   = true
  special = false
}

resource "azurerm_linux_function_app" "main" {
  name                        = var.function_app_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  service_plan_id             = var.function_app_plan_id
  https_only                  = var.function_app_https_only
  functions_extension_version = var.functions_app_extension_version

  storage_account_name        = var.function_app_storage_account_name
  storage_account_access_key  = var.function_app_storage_account_primary_access_key

  site_config {
    always_on                        = var.function_app_always_on
    app_scale_limit                  = var.function_app_scale_limit
    elastic_instance_minimum         = var.function_app_elastic_instance_minimum
    pre_warmed_instance_count        = var.function_app_pre_warmed_instance_count
    runtime_scale_monitoring_enabled = var.function_app_runtime_scale_monitoring_enabled
    health_check_path                = var.function_app_health_check_path
    http2_enabled                    = var.function_app_http2_enabled
    minimum_tls_version              = var.function_app_min_tls_version
    vnet_route_all_enabled           = var.function_app_vnet_route_all_enabled 
    websockets_enabled               = var.function_app_websockets_enabled
    ftps_state                       = "Disabled"

    application_stack {
      dotnet_version          = lookup(local.app_stack, "dotnet_version", null)
      java_version            = lookup(local.app_stack, "java_version", null)
      node_version            = lookup(local.app_stack, "node_version", null)
      python_version          = lookup(local.app_stack, "python_version", null)
      powershell_core_version = lookup(local.app_stack, "powershell_core_version", null)
    }

    dynamic "ip_restriction" {
      for_each = var.function_app_ip_restriction 
      iterator = i
      content {
        name                      = lookup(i.value, "name", null)
        action                    = lookup(i.value, "action", null)
        ip_address                = lookup(i.value, "ip_address", null)
        priority                  = lookup(i.value, "priority", null)
        virtual_network_subnet_id = lookup(i.value, "virtual_network_subnet_id", null)

        dynamic "headers" {
          for_each = i.value.headers
          content {
            x_azure_fdid      = lookup(headers.value, "x_azure_fdid", null)
            x_fd_health_probe = lookup(headers.value, "x_fd_health_probe", null)
            x_forwarded_for   = lookup(headers.value, "x_forwarded_for", null)
            x_forwarded_host  = lookup(headers.value, "x_forwarded_host", null)
          }
        }
      }
    }

    cors {
      allowed_origins     = var.function_app_cors_allowed_origins
      support_credentials = var.function_app_cors_support_credentials
    } 
  }  

  app_settings = merge(var.function_app_settings, local.app_settings, local.auth_settings)

  dynamic "connection_string" {
    for_each = var.function_app_connection_string
    iterator = s
    content {
      name  = s.key
      value = s.value.value
      type  = s.value.type
    }
  }

  identity {
    type = (local.identity.enabled || var.function_app_key_vault_id != null ?
      (local.identity.ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned") :
      "None"
    )
    identity_ids = local.identity.ids
  }

  dynamic "auth_settings" {
    for_each = var.function_app_auth_provider != null ? [1] : []
    content {
      enabled             = true
      token_store_enabled = true
      issuer              = coalesce(var.function_app_auth_issuer, format("https://sts.windows.net/%s/v2.0", data.azurerm_client_config.main.tenant_id))
      default_provider    = var.function_app_auth_provider

      dynamic "active_directory" {
        for_each = var.function_app_auth_provider == "AzureActiveDirectory" ? [1] : []
        content {
          client_id                  = var.function_app_auth_key
          client_secret_setting_name = "PROVIDER_AUTHENTICATION_SECRET"
          allowed_audiences          = var.function_app_auth_scopes
        }
      }
      
      dynamic "microsoft" {
        for_each = var.function_app_auth_provider == "MicrosoftAccount" ? [1] : []
        content {
          client_id                  = var.function_app_auth_key
          client_secret_setting_name = "PROVIDER_AUTHENTICATION_SECRET"
          oauth_scopes               = var.function_app_auth_scopes
        }
      }

      dynamic "google" {
        for_each = var.function_app_auth_provider == "Google" ? [1] : []
        content {
          client_id                  = var.function_app_auth_key
          client_secret_setting_name = "PROVIDER_AUTHENTICATION_SECRET"
          oauth_scopes               = var.function_app_auth_scopes
        }
      }

      dynamic "github" {
        for_each = var.function_app_auth_provider == "Github" ? [1] : []
        content {
          client_id                  = var.function_app_auth_key
          client_secret_setting_name = "PROVIDER_AUTHENTICATION_SECRET"
          oauth_scopes               = var.function_app_auth_scopes
        }
      }
      
      dynamic "facebook" {
        for_each = var.function_app_auth_provider == "Facebook" ? [1] : []
        content {
          app_id                  = var.function_app_auth_key
          app_secret_setting_name = "PROVIDER_AUTHENTICATION_SECRET"
          oauth_scopes            = var.function_app_auth_scopes
        }
      }

      dynamic "twitter" {
        for_each = var.function_app_auth_provider == "Twitter" ? [1] : []
        content {
          consumer_key                 = var.function_app_auth_key
          consumer_secret_setting_name = "PROVIDER_AUTHENTICATION_SECRET"
        }
      }
    }
  }

  tags = var.tags
}

resource "azurerm_app_service_custom_hostname_binding" "main" {
  count               = var.function_app_custom_hostname != null ? 1 : 0
  hostname            = var.function_app_custom_hostname
  app_service_name    = var.function_app_name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_linux_function_app.main]

  lifecycle {
    ignore_changes = [ssl_state, thumbprint]
  }
}

resource "azurerm_key_vault_access_policy" "identity" {
  count                   = var.function_app_key_vault_id != null ? 1 : 0
  key_vault_id            = var.function_app_key_vault_id
  tenant_id               = azurerm_linux_function_app.main.identity[0].tenant_id
  object_id               = azurerm_linux_function_app.main.identity[0].principal_id
  certificate_permissions = ["Get"]
  secret_permissions      = ["Get"]
}

resource "azurerm_app_service_certificate" "main" {
  count               = var.function_app_key_vault_certificate_secret_id != null ? 1 : 0
  name                = format("cert-%s", replace(var.function_app_custom_hostname, ".", "_dot_"))
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_secret_id = var.function_app_key_vault_certificate_secret_id
  depends_on          = [azurerm_key_vault_access_policy.identity]
}

resource "azurerm_app_service_certificate_binding" "main" {
  count               = var.function_app_key_vault_certificate_secret_id != null ? 1 : 0
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.main[0].id
  certificate_id      = azurerm_app_service_certificate.main[0].id
  ssl_state           = "SniEnabled"
  depends_on          = [azurerm_app_service_custom_hostname_binding.main, azurerm_app_service_certificate.main]
}
