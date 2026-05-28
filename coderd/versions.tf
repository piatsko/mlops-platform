terraform {
  required_version = ">= 1.6.0"

  required_providers {
    coderd = {
      source  = "coder/coderd"
      version = "~> 0.0.16"
    }
  }
}
