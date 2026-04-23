//// outputs.tf

# retrieve the generated names:
output "generated_vm_name" {
  value = kubernetes_manifest.vcfcli_vm.object.metadata.name
}

output "generated_subnet_name" {
  value = kubernetes_manifest.vcfcli_subnet.object.metadata.name
}

output "generated_lb_name" {
  value = kubernetes_manifest.vcfcli_lb.object.metadata.name
}