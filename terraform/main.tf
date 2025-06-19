provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = var.region

  template {
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
        "run.googleapis.com/vpc-egress"           = "all-traffic"
      }
    }
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
  api_id = "simpletimeservice-api"
  display_name = "Simple Time API"
}

resource "google_api_gateway_api_config" "config" {
  api      = google_api_gateway_api.api.id
  config_id = "v1"
  openapi_documents {
    document {
      path     = "${path.module}/openapi.yaml"
      contents = file("${path.module}/openapi.yaml")
    }
  }
}

resource "google_api_gateway_gateway" "gateway" {
  name        = "simpletimeservice-gateway"
  api_config  = google_api_gateway_api_config.config.id
  location    = var.region
}


