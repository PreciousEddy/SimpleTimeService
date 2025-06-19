terraform {
  backend "gcs" {
    bucket = "simpleapp-state"
    prefix = "simpletimeservice/state"
  }
}
