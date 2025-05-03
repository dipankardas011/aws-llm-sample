terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
}


variable "github_profile" {
  description = "GitHub profile name"
  type        = string
}

data "http" "github_keys" {
  url = "https://github.com/${var.github_profile}.keys"
}

locals {
  ssh_keys = split("\n", trimspace(data.http.github_keys.response_body))
}

output "public_ssh_key" {
  value       = local.ssh_keys[0]
  description = "Public SSH key fetched from GitHub"
}
