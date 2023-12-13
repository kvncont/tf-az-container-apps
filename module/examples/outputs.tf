output "kv_endpoint" {
  value = module.my_solution.kv_endpoint
}

output "managed_identity_object_id" {
  value = module.my_solution.managed_identity_object_id
}

output "container_apps_endpoint" {
  value = "https://${module.my_solution.container_apps_endpoint}"
}
