output "kv_endpoint" {
  value = module.container_apps_solution.kv_endpoint
}

output "managed_identity_object_id" {
  value = module.container_apps_solution.managed_identity_object_id
}

output "container_apps_endpoint" {
  value = "https://${module.container_apps_solution.container_apps_endpoint}"
}
