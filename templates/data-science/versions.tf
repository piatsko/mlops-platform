terraform {
  required_version = ">= 1.6.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = "~> 2.18"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
  }
}

provider "coder" {}

# Runs inside the kind cluster via Coder's provisioner pod (in-cluster service account).
# For local tofu plan/apply outside the cluster set KUBE_CONFIG_PATH.
provider "kubernetes" {}
