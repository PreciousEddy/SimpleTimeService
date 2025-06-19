resource "google_compute_network" "main" {
  name = "simpletimeservice-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public" {
  count        = 2
  name         = "public-subnet-${count.index}"
  ip_cidr_range = "10.0.${count.index}.0/24"
  region       = var.region
  network      = google_compute_network.main.id
  purpose      = "PRIVATE"
}

resource "google_compute_subnetwork" "private" {
  count        = 2
  name         = "private-subnet-${count.index}"
  ip_cidr_range = "10.0.1${count.index}.0/24"
  region       = var.region
  network      = google_compute_network.main.id
  purpose      = "PRIVATE"
}

resource "google_vpc_access_connector" "connector" {
  name         = "serverless-vpc-connector"
  region       = var.region
  network      = google_compute_network.main.name
  ip_cidr_range = "10.8.0.0/28"
}
