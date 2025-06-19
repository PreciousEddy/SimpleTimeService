# 🚀 SimpleTimeService

A minimal Flask-based microservice that returns the current UTC timestamp and the client IP in JSON format.

Deployed using Terraform to **Google Cloud Run**, behind an **API Gateway**, with infrastructure managed via a **remote state backend in GCS** and a VPC connector.

---

### JSON Output

```
{
  "timestamp": "2025-06-19T21:00:00Z",
  "ip": "34.102.115.25"
}
```


- Returns JSON with `timestamp` and `ip`
- Dockerized, non-root user container
- Deployed to GCP Cloud Run via Terraform
- CI/CD enabled using GitHub Actions

---

##  Run Locally with Docker

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/)

### Build & Run

```
docker build -t simpletimeservice ./app
docker run -p 5000:5000 simpletimeservice
```

### Test
Open in broswer http://localhost:5000
or with curl ```curl http://localhost:5000```

### Deploy to GCP with Terraform

### Prerequisties
- Terraform
- gcloud CLI
- A GCP Project with Billing Enabled
- Cloud RUN API enabled

### Setup GCP Credentials

1. Create a service account in IAM with the following roles:
   - Cloud RUN Admin
   - IAM Service Account User
   - Viewer
2. Generate a JSON key and download it.

### COnfigure terraform Remote Backend:
Edit ```terraform/backend.tf```

```
terraform {
backend "gcs" {
bucket = "your-tf-state-bucket"
prefix = "simpletimeservice/state"
} 
  }
```
Ensure GCS bucket exists and has versioning enabled

### GitHub Actions (CI/CD)

This repo includes a workflow that:

 - Builds and pushes Docker image to Docker Hub

 - Applies Terraform to deploy to GCP

### Required GitHub Secrets
| Name               | Description                                      |
|--------------------|--------------------------------------------------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username                      |
| `DOCKERHUB_TOKEN`    | Docker Hub access token (create from DockerHub) |
| `GCP_CREDENTIALS`    | Contents of your GCP service account JSON key  |

Secrets should be added under:
Repo → Settings → Secrets and variables → Actions

### Workflow File Location

`.github/workflows/deploy.yml`

This file defines the CI/CD pipeline that will:

1. Authenticate to Docker Hub and GCP
2. Build and push your Docker image to Docker Hub
3. Run `terraform init` and `terraform apply` to provision and deploy your app on GCP Cloud Run