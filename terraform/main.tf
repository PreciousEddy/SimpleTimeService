provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.docker_image
        ports {
          container_port = 5000
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloud_run_service.default.location
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_api_gateway_api" "api" {
  api_id       = "simpletimeservice-api"
  display_name = "Simple Time API"
}

# API Config without openapi.yaml file
resource "google_api_gateway_api_config" "config" {
  api       = google_api_gateway_api.api.id
  config_id = "v1"

  openapi_documents {
    document {
      contents = <<EOT
swagger: '2.0'
info:
  title: Simple Time Service API
  description: Simple service to return current time and requester IP
  version: 1.0.0
host: simpletimeservice.api.gateway.dev
x-google-endpoints:
  - name: simpletimeservice.api.gateway.dev
    allowCors: true
paths:
  /:
    get:
      operationId: getTime
      responses:
        '200':
          description: OK
      x-google-backend:
        address: "${google_cloud_run_service.default.status[0].url}"
      security: []
EOT
    }
  }
}

resource "google_api_gateway_gateway" "gateway" {
  name       = "simpletimeservice-gateway"
  api_config = google_api_gateway_api_config.config.id
  location   = var.region
}

output "cloud_run_url" {
  value = google_cloud_run_service.default.status[0].url
}

output "api_gateway_url" {
  value = "https://${google_api_gateway_gateway.gateway.default_hostname}"
}



