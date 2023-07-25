variable "function_app_name" {
  type        = string
  description = "The name of the web app."
}

variable "resource_group_name" {
  type        = string
  description = "The name of an existing resource group to use for the web app."
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
}

variable "function_app_plan_id" {
  type        = string
  description = "The ID of the App Service Plan."
}

variable "function_app_settings" {
  type        = map(string)
  default     = {}
  description = "Set app settings. These are avilable as environment variables at runtime."
}

variable "function_app_connection_string" {
  type        = map(any)
  default     = {}
  description = "Set connection string. These are avilable as environment variables at runtime."
}

variable "function_app_key_vault_id" {
  type        = string
  default     = null
  description = "The ID of an existing Key Vault. Required if `secure_app_settings` is set."
}

variable "function_app_key_vault_certificate_secret_id" {
  type        = string
  default     = null
  description = "The ID of an existing certificate sercret Key Vault."
}

variable "function_app_always_on" {
  type        = bool
  default     = false
  description = "Either `true` to ensure the web app gets loaded all the time, or `false` to to unload after being idle."
}

variable "function_app_https_only" {
  type        = bool
  default     = true
  description = "Redirect all traffic made to the web app using HTTP to HTTPS."
}

variable "function_app_client_affinity_enabled" {
  type        = bool
  default     = false
  description = "Set the FTPS state value the web app. The options are: `AllAllowed`, `Disabled` and `FtpsOnly`."
}

variable "function_app_allowed_origins" {
  type        = string
  default     = null
  description = "Set the FTPS state value the web app. The options are: `AllAllowed`, `Disabled` and `FtpsOnly`."
}

variable "function_app_ip_restriction" {
  type        = list(any)
  default     = []
  description = "A list of restrictions by IP."
}

variable "function_app_identity" {
  type        = any
  default     = {}
  description = "Managed service identity properties."
}

variable "function_app_auth_provider" {
  type        = string
  default     = null
  description = "provider"
}

variable "function_app_auth_issuer" {
  type        = string
  default     = null
  description = "provider"
}

variable "function_app_auth_scopes" {
  type        = list(any)
  default     = null
  description = "provider"
}

variable "function_app_auth_key" {
  type        = string
  default     = null
  description = "Auth parameter key provider."
}

variable "function_app_auth_secret" {
  type        = string
  default     = null
  description = "Auth parameter secret provider."
}

variable "function_app_storage_account_name" {
  type        = string
  description = ""
}

variable "function_app_contentshare_name" {
  type        = string
  default     = null
  description = ""
}

variable "function_app_package_name" {
  type        = string
  default     = "functions.zip"
  description = "Zip deployment name for Azure Functions."
}

variable "function_app_storage_account_primary_access_key" {
  type        = string
  description = ""
}

variable "function_app_storage_account_primary_connection_string" {
  type        = string
  description = ""
}

variable "function_app_scale_limit" {
  type        = number
  default     = null
  description = ""
}

variable "function_app_elastic_instance_minimum" {
  type        = number
  default     = null
  description = ""
}

variable "function_app_pre_warmed_instance_count" {
  type        = number
  default     = null
  description = ""
}

variable "function_app_runtime_scale_monitoring_enabled" {
  type        = bool
  default     = false
  description = ""
}

variable "function_app_health_check_path" {
  type        = string
  default     = null
  description = ""
}

variable "function_app_http2_enabled" {
  type        = bool
  default     = false
  description = ""
}

variable "function_app_runtime_name" {
  type        = string
  default     = "node"
  description = ""
}

variable "function_app_runtime_version" {
  type        = string
  default     = null
  description = ""
}

variable "functions_app_extension_version" {
  type        = string
  default     = "~4"
  description = ""
}

variable "function_app_min_tls_version" {
  type        = string
  default     = "1.2"
  description = ""
}

variable "function_app_vnet_route_all_enabled" {
  type        = bool
  default     = false
  description = ""
}

variable "function_app_websockets_enabled" {
  type        = bool
  default     = true
  description = ""
}

variable "function_app_cors_allowed_origins" {
  type        = list(string)
  default     = []
  description = ""
}

variable "function_app_cors_support_credentials" {
  type        = any
  default     = false
  description = ""
}

variable "function_app_custom_hostname" {
  type        = string
  default     = null
  description = "Custom Hostname to use for the function"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the function app."
}

locals {

  app_map = {
    node = {
      node_version            = coalesce(var.function_app_runtime_version, "16")
    }
    dotnet = {
      dotnet_version          = coalesce(var.function_app_runtime_version, "7.0")
    }
    java = {
      java_version            = coalesce(var.function_app_runtime_version, "17")
    }
    python = {
      python_version          = coalesce(var.function_app_runtime_version, "3.9")
    }
    powershell_core = {
      powershell_core_version = coalesce(var.function_app_runtime_version, "7.2")
    }
  }

  app_stack = merge({
    dotnet_version          = null
    java_version            = null
    node_version            = null
    python_version          = null
    powershell_core_version = null
  }, local.app_map[var.function_app_runtime_name])

  app_settings = {
    "WEBSITE_CONTENTSHARE"                     = coalesce(var.function_app_contentshare_name, format("%s-%s", var.function_app_name, random_string.main.result))
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = format("DefaultEndpointsProtocol=https;AccountName=%s;AccountKey=%s;EndpointSuffix=core.windows.net", var.function_app_storage_account_name, var.function_app_storage_account_primary_access_key),
    "AzureWebJobsDisableHomepage"              = "true",
  }

  auth_settings = {
    "PROVIDER_AUTHENTICATION_SECRET" = var.function_app_auth_secret
  }

  identity = merge({
    enabled = true
    ids     = null
  }, var.function_app_identity)

}
