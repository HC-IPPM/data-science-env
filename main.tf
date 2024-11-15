provider "google" {
  #credentials = file("<PATH_TO_YOUR_SERVICE_ACCOUNT_JSON>")
  project     = "${var.project_id}"
  region      = "${var.region}"
}

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network-vertax-workbench"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-vertax-workbench"
  ip_cidr_range = "10.0.0.0/16"
  region        = "${var.region}"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_notebooks_instance" "vertex_ai_workbench" {
  name          = "vertex-ai-workbench"
  location      = "${var.region}"
  machine_type  = "n1-standard-4"
  vm_image {
    project     = "deeplearning-platform-release"
    image_family = "tf2-ent-lts-2-3-cu110-notebooks"
  }
  boot_disk_type = "pd-ssd"
  network        = google_compute_network.vpc_network.self_link
  subnet         = google_compute_subnetwork.subnet.self_link
  no_public_ip   = true
}

resource "google_compute_router" "router" {
  name    = "router-vertax-workbench"
  network = google_compute_network.vpc_network.self_link
  region  = "${var.region}"
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-vertax-workbench"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# below are dataplex related resources(4), will on be created if dataplex option is enabled 
resource "google_dataplex_lake" "lake" {
  count = var.dataplex_option == true ? 1 : 0
  location     = "${var.zone}"
  name         = "lake"
  description  = "Lake for dataplex"
} 

resource "google_dataplex_zone" "zone" {
  count = var.dataplex_option == true ? 1 : 0
  discovery_spec {
    enabled = false
  }

  lake     = google_dataplex_lake.lake.name
  location = "${var.zone}"
  name     = "zone"

  resource_spec {
    location_type = "MULTI_REGION"
  }

  type         = "RAW"
  description  = "Zone for dataplex"
  project      = "${var.project_id}"
  labels       = {}
}

resource "google_storage_bucket" "dataplex_bucket" {
  count = var.dataplex_option == true ? 1 : 0
  name          = "bucket"
  location      = "${var.region}"
  uniform_bucket_level_access = true
  lifecycle {
    ignore_changes = [
      labels
    ]
  }

  project = "${var.project_id}"
}

resource "google_dataplex_asset" "asset" {
  count = var.dataplex_option == true ? 1 : 0
  name          = "asset"
  location      = "${var.region}"

  lake = google_dataplex_lake.lake.name
  dataplex_zone = google_dataplex_zone.zone.name

  discovery_spec {
    enabled = false
  }

  resource_spec {
    type = "STORAGE_BUCKET"
  }

  labels = {
    my-asset = "exists"
  }


  project = "${var.project_id}"
  depends_on = [
    google_storage_bucket.dataplex_bucket
  ]
}