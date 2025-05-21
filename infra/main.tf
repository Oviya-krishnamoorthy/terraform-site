provider "google" {
  project = var.project_id
  region  = var.region
}

# Static Website Bucket
resource "google_storage_bucket" "website_bucket" {
  name                        = var.bucket_name
  location                    = "us-central1"
  force_destroy               = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  uniform_bucket_level_access = true
}

# Public access to objects
resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "roles/storage.objectViewer"
  members = ["allUsers"]
}

# Upload index.html from website folder
resource "google_storage_bucket_object" "index_html" {
  name         = "index.html"
  bucket       = google_storage_bucket.website_bucket.name
  source       = "${path.module}/../website/index.html"
  content_type = "text/html"
}

# DNS Managed Zone
resource "google_dns_managed_zone" "portfolio_zone" {
  name        = "portfolio"
  dns_name    = var.domain_name
  description = "Managed by Terraform"
  dnssec_config {
    state = "off"
  }
}

# A Record pointing domain to website IP (replace with correct IP or Load Balancer IP)
resource "google_dns_record_set" "a_record" {
  name         = var.domain_name
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.portfolio_zone.name
  rrdatas      = ["34.54.202.153"]
}

# Output DNS name servers
output "dns_name_servers" {
  value = google_dns_managed_zone.portfolio_zone.name_servers
}
