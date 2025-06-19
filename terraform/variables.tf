variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Name for Cloud Run service"
  type        = string
  default     = "simpletimeservice"
}

variable "docker_image" {
  description = "Docker image to deploy"
  type        = string
}
