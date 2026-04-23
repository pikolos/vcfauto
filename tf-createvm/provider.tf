//// provider.tf
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
  }
}
provider "kubernetes" {
  config_path = "/home/gregory.oldyck@arn.rainpole.io/.kube/config" # Use your local kubeconfig file
  config_context = "nemea:greg01-b2y9g:gregory-oldyck"
}
