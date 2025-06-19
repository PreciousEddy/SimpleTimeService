# SimpleTimeService

A minimal Flask-based microservice that returns the current UTC timestamp and the client IP in JSON format.

Deployed using Terraform to **AWS ECS Fargate**, behind an **Application Load Balancer (ALB)**, with infrastructure managed via a **remote S3 backend with DynamoDB state locking**.

---

### JSON Output

````
{
  "timestamp": "2025-06-19T21:00:00Z",
  "ip": "34.102.115.25"
}
````

* Returns JSON with `timestamp` and `ip`
* Dockerized, non-root user container
* Deployed to AWS ECS (Fargate) via Terraform
* CI/CD enabled using GitHub Actions

---

## Run Locally with Docker

### Prerequisites

* [Docker](https://docs.docker.com/get-docker/)

### Build & Run

```
docker build -t simpletimeservice ./app
docker run -p 5000:5000 simpletimeservice
```

### Test

* Open in browser: [http://localhost:5000](http://localhost:5000)
* Or test with curl:

```
curl http://localhost:5000
```

---

## Deploy to AWS with Terraform

### Prerequisites

* [Terraform](https://developer.hashicorp.com/terraform/install)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* AWS IAM user with access keys & these policies:

   * AmazonEC2FullAccess
   * AmazonECS\_FullAccess
   * AmazonS3FullAccess
   * IAMFullAccess
   * CloudWatchFullAccess
  
* Create:

   * S3 bucket (e.g., `simpletime-tfstate`)
   * DynamoDB table (`terraform-locks`) with `LockID` as primary key

---

### Configure AWS Credentials

```
aws configure
```

Or set environment variables:

```bash
export AWS_ACCESS_KEY_ID=your_key_id
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_DEFAULT_REGION=us-east-1
```

---

### Terraform Backend Configuration

Edit `terraform/backend.tf`:

```
terraform {
  backend "s3" {
    bucket         = "simpletime-tfstate"
    key            = "ecs/app.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

Then run:

```
terraform init
terraform apply -var="docker_image=your_dockerhub_username/simpletimeservice:latest"
```

---

## GitHub Actions (CI/CD)

This repo includes a workflow that:

* Builds and pushes Docker image to Docker Hub
* Applies Terraform to deploy to AWS

### Required GitHub Secrets

| Name                     | Description                                       |
| ------------------------ | ------------------------------------------------- |
| DOCKERHUB\_USERNAME      | Your Docker Hub username                          |
| DOCKERHUB\_TOKEN         | Docker Hub access token (generate from DockerHub) |
| AWS\_ACCESS\_KEY\_ID     | IAM user access key                               |
| AWS\_SECRET\_ACCESS\_KEY | IAM user secret key                               |

Secrets should be added under:
Repo → Settings → Secrets and variables → Actions

---

### Workflow File Location

`.github/workflows/deploy.yml`

This file defines the CI/CD pipeline that will:

1. Authenticate to Docker Hub and AWS
2. Build and push your Docker image to Docker Hub
3. Run `terraform init`, `terraform plan`, and `terraform apply` to provision and deploy your app on AWS ECS (Fargate)

---

## Accessing the App

Once deployed, Terraform will output the public ALB DNS.

You can access the app at:

```
http://simpletimeservice-lb-915859264.us-east-1.elb.amazonaws.com/
```

---

## Project Structure

```
.
├── app/                     # Flask app and Dockerfile
├── terraform/               # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   └── terraform.tfvars
├── .github/
│   └── workflows/
│       └── deploy.yml       # CI/CD Pipeline
├── .gitignore
└── README.md
```


