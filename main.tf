resource "google_compute_network" "vpc_network" {
  name = "terraform-vpc-network"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet1-terraform-vpc" {
  name          = "terraform-vpc-subnetwork-1"
  ip_cidr_range = "10.10.10.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.self_link
  }
resource "google_compute_subnetwork" "subnet2-terraform-vpc" {
  name          = "terraform-vpc-subnetwork-2"
  ip_cidr_range = "10.10.20.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.self_link
  }

resource "google_compute_instance" "terraform-gce-1" {
  name         = "terraform-gce-1"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  tags = ["env", "test"]

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20240611"
      labels = {
        my_label = "test"
      }
    }
  }
  
  network_interface {
    network = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet1-terraform-vpc.id
    access_config {
      // Ephemeral public IP
    }
  }
  service_account {
    email  = "vm-sa-567@terraform-nk.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
}
}
resource "google_compute_instance" "terraform-gce-2" {
  name         = "terraform-gce-2"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  tags = ["env", "prod"]

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20240611"
      labels = {
        my_label = "prod"
      }
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet2-terraform-vpc.id
  access_config {
      // Ephemeral public IP
  }
  }
  service_account {
    email = "vm-sa-567@terraform-nk.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
output "vpc_network-URI" {
  value = google_compute_network.vpc_network.network_firewall_policy_enforcement_order
}
output "gce1-IP-address" {
  value =  google_compute_instance.terraform-gce-1.network_interface.0.network_ip
}
output "gce2-IP-address" {
  value =  google_compute_instance.terraform-gce-2.network_interface.0.network_ip
  
}
