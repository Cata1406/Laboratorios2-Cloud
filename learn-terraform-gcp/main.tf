# Configuración de Terraform
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

# Define el proveedor de Google Cloud Platform
provider "google" {
  project = "laboratorio-cloud-run"
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Define la red de Compute Engine
resource "google_compute_network" "vpc_network" {
  name = "custom-terraform-network"
}

# Define la instancia de Compute Engine
resource "google_compute_instance" "vm_instance" {
    name = "terraform-instance-1"
    zone = "us-central1-a"
    machine_type = "e2-micro"
    tags = ["web", "uniandes"]
    boot_disk {
      initialize_params {
      image = "cos-cloud/cos-stable"
      }
    }

    network_interface {
        network = google_compute_network.vpc_network.name
        access_config {
        }
    }
}


# Define el bucket de Cloud Storage
resource "google_storage_bucket" "app_bucket" {
    name = "uniandes-storage-bucket-1"
    location = "US"
    # Esto permite que Terraform elimine el bucket si se elimina el recurso
    force_destroy = true
    # Habilita uniform access control
    uniform_bucket_level_access = false
    }

resource "google_storage_bucket_object" "objeto_publico" {
 name = "archivo_publico.txt"
 bucket = google_storage_bucket.app_bucket.name
 content = "Este objeto será público."
}

# Establece acceso público para los nuevos objetos que se almacenen
resource "google_storage_object_access_control" "public_rule" {
    object = google_storage_bucket_object.objeto_publico.output_name
    bucket = google_storage_bucket.app_bucket.name
    role = "READER"
    entity = "allUsers"
}

resource "google_storage_bucket_object" "new_txt_file" {
  name = "file.txt"
  source = "files/file.txt"
  bucket = google_storage_bucket.app_bucket.name
}