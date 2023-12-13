output "kv_endpoint" {
  value       = azurerm_key_vault.solution.vault_uri
  description = "Key Vault Endpoint"
}

output "managed_identity_object_id" {
  value       = azurerm_user_assigned_identity.solution.principal_id
  description = "Managed Identity Object ID"
}

output "container_apps_endpoint" {
  value       = azurerm_container_app.solution.latest_revision_fqdn
  description = "Container Apps Endpoint"
}
