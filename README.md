# terraform-azurerm-function-app
Terraform module that can be used to create an Azure Function.

## Usage
See `examples` folders for usage of this module.

## Requirements

| Name | Version |
|------|---------|
| terraform | 1.5.3 |
| azurerm | 3.66.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | 3.66.0 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|:-----:|:-----:|
| function_app_name | The name of the web app. | `string` | n/a | yes |
| resource_group_name | The name of an existing resource group to use for the web app. | `string` | n/a | yes |
| location | Specifies the supported Azure location where the resource exists. | `string` | n/a | yes |
| function_app_plan_id | The ID of the App Service Plan. | `string` | n/a | yes |
| function_app_settings | Set app settings. These are available as environment variables at runtime. | `map(string)` | `{}` | no |
| function_app_connection_string | Set connection string. These are available as environment variables at runtime. | `map(any)` | `{}` | no |
| function_app_key_vault_id | The ID of an existing Key Vault. Required if `secure_app_settings` is set. | `string` | `null` | no |
| function_app_key_vault_certificate_secret_id | The ID of an existing certificate secret Key Vault. | `string` | `null` | no |
| function_app_always_on | Either `true` to ensure the web app gets loaded all the time, or `false` to unload after being idle. | `bool` | `false` | no |
| function_app_https_only | Redirect all traffic made to the web app using HTTP to HTTPS. | `bool` | `true` | no |
| function_app_client_affinity_enabled | Set the FTPS state value the web app. The options are: `AllAllowed`, `Disabled` and `FtpsOnly`. | `bool` | `false` | no |
| function_app_allowed_origins | Set the FTPS state value the web app. The options are: `AllAllowed`, `Disabled` and `FtpsOnly`. | `string` | `null` | no |
| function_app_ip_restriction | A list of restrictions by IP. | `list(any)` | `[]` | no |
| function_app_identity | Managed service identity properties. | `any` | `{}` | no |
| function_app_auth_provider | Authentication provider. | `string` | `null` | no |
| function_app_auth_issuer | Authentication provider issuer. | `string` | `null` | no |
| function_app_auth_scopes | Authentication provider scopes. | `list(any)` | `null` | no |
| function_app_auth_key | Authentication parameter key provider. | `string` | `null` | no |
| function_app_auth_secret | Authentication parameter secret provider. | `string` | `null` | no |
| function_app_storage_account_name | Storage account name to be used by the web app. | `string` | n/a | yes |
| function_app_contentshare_name | Content share name for the web app. | `string` | `null` | no |
| function_app_package_name | Zip deployment name for Azure Functions. | `string` | "functions.zip" | no |
| function_app_storage_account_primary_access_key | Primary access key for the storage account to be used by the web app. | `string` | n/a | yes |
| function_app_storage_account_primary_connection_string | Primary connection string for the storage account to be used by the web app. | `string` | n/a | yes |
| function_app_scale_limit | Scaling limit for the web app. | `number` | `null` | no |
| function_app_elastic_instance_minimum | Minimum number of instances for elastic scaling. | `number` | `null` | no |
| function_app_pre_warmed_instance_count | Number of pre-warmed instances. | `number` | `null` | no |
| function_app_runtime_scale_monitoring_enabled | Enable or disable runtime scale monitoring. | `bool` | `false` | no |
| function_app_health_check_path | Health check path for the web app. | `string` | `null` | no |
| function_app_http2_enabled | Enable or disable HTTP2. | `bool` | `false` | no |
| function_app_runtime_name | Runtime name for the web app. | `string` | "node" | no |
| function_app_runtime_version | Runtime version for the web app. | `string` | `null` | no |
| functions_app_extension_version | Extension version for Azure Functions. | `string` | "~4" | no |
| function_app_min_tls_version | Minimum TLS version for the web app. | `string` | "1.2" | no |
| function_app_vnet_route_all_enabled | Enable or disable routing all network| function_app_vnet_route_all_enabled | Enable or disable routing all network traffic through the VNet for the web app. | bool | false | no | | function_app_websockets_enabled | Enable or disable websockets for the web app. | bool | true | no | | function_app_cors_allowed_origins | List of allowed origins for CORS. | list(string) | [] | no | | function_app_cors_support_credentials | Enable or disable support for CORS credentials. | any | false | no | | function_app_custom_hostname | Custom Hostname to use for the function. | string | null | no | | tags | A mapping of tags to assign to the function app. | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Function App. |
| name | The name of the Function App. |
| hostname | The default hostname for the Function App. |
| domain_verification_id | An identifier used by App Service to perform domain ownership verification via DNS TXT record. |
| outbound_ips | A list of outbound IP addresses for the Function App. |
| possible_outbound_ips | A list of possible outbound IP addresses for the Function App. Superset of outbound_ips. |
| plan | A mapping of Function App plan properties. |
| identity | A mapping of identity properties for the web app. |
