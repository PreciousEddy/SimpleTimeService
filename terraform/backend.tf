terraform {
  backend "s3" {
    bucket         = "simpletime-tfstate"
    key            = "ecs/app.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
