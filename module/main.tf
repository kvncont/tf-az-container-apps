locals {
  rg_name  = "rg-${var.solution_name}-${var.location}"
  id_name  = "id-${var.solution_name}-${var.location}"
  kv_name  = "kv-${var.solution_name}-${var.location}"
  cae_name = "cae-${var.solution_name}-${var.location}"
  ca_name  = "ca-${var.solution_name}-${var.location}"
  log_name = "log-${var.solution_name}-${var.location}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "solution" {
  name     = local.rg_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "solution" {
  name                = local.id_name
  location            = azurerm_resource_group.solution.location
  resource_group_name = azurerm_resource_group.solution.name
}

resource "azurerm_role_assignment" "solution_owner" {
  scope                = azurerm_resource_group.solution.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.solution.principal_id
}

resource "azurerm_key_vault" "solution" {
  name                        = local.kv_name
  location                    = azurerm_resource_group.solution.location
  resource_group_name         = azurerm_resource_group.solution.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}

resource "azurerm_key_vault_access_policy" "root" {
  key_vault_id = azurerm_key_vault.solution.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
    "Release",
    "Rotate",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get", "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update"
  ]

  storage_permissions = [
    "Backup",
    "Delete",
    "DeleteSAS",
    "Get",
    "GetSAS",
    "List",
    "ListSAS",
    "Purge",
    "Recover",
    "RegenerateKey",
    "Restore",
    "Set",
    "SetSAS",
    "Update"
  ]
}

resource "azurerm_key_vault_access_policy" "solution_" {
  key_vault_id = azurerm_key_vault.solution.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.solution.principal_id

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
    "Release",
    "Rotate",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get", "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update"
  ]

  storage_permissions = [
    "Backup",
    "Delete",
    "DeleteSAS",
    "Get",
    "GetSAS",
    "List",
    "ListSAS",
    "Purge",
    "Recover",
    "RegenerateKey",
    "Restore",
    "Set",
    "SetSAS",
    "Update"
  ]
}

resource "azurerm_log_analytics_workspace" "solution" {
  name                = local.log_name
  location            = azurerm_resource_group.solution.location
  resource_group_name = azurerm_resource_group.solution.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "solution" {
  name                       = local.cae_name
  location                   = azurerm_resource_group.solution.location
  resource_group_name        = azurerm_resource_group.solution.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.solution.id
}

resource "azurerm_container_app" "solution" {
  name                         = local.ca_name
  container_app_environment_id = azurerm_container_app_environment.solution.id
  resource_group_name          = azurerm_resource_group.solution.name
  revision_mode                = "Single"

  ingress {
    target_port      = 8080
    external_enabled = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = "cloud-native-app"
      image  = "docker.io/kvncont/cloud-native-app:v1.0.0"
      cpu    = 0.25
      memory = "0.5Gi"
    }
    min_replicas = 0
    max_replicas = 2
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.solution.id
    ]
  }
}
