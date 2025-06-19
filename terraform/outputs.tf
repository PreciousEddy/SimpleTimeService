output "cloud_run_url" {
  value = google_cloud_run_service.default.status[-1].url
}

output "api_gateway_url" {
  value = "https://${google_api_gateway_gateway.gateway.default_hostname}"
}