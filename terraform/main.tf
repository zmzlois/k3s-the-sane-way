terraform {
  required_providers {
    contabo = {
      source  = "contabo/contabo"
      version = "5.0.0"
    }
  }
}

provider "contabo" {
  oauth2_client_id     = var.oauth2_client_id
  oauth2_client_secret = var.oauth2_client_secret
  oauth2_user          = var.oauth2_user
  oauth2_pass          = var.oauth2_pass
}

# Create a default contabo VPS instance
resource "contabo_instance" "k8s_master" {
  existing_instance_id = contabo.k8s_master.id
  ssh_keys             = var.master.ssh_keys
}

resource "contabo_instance" "k8s_worker_1" {
  existing_instance_id = contabo.k8s_worker_1.id
  ssh_keys             = var.worker_1.ssh_keys
}

resource "contabo_instance" "k8s_worker_2" {
  existing_instance_id = contabo.k8s_worker_2.id
  ssh_keys             = var.worker_2.ssh_keys
}


# Output our newly created instances
output "master_output" {
  description = "Master node instance"
  value       = contabo.output
}
