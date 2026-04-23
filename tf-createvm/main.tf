//// main.tf
# ---------------------------------------------------------
# VirtualMachineService LoadBalancer
# ---------------------------------------------------------
resource "kubernetes_manifest" "terravcf_lb" {
  manifest = {
    apiVersion = "vmoperator.vmware.com/v1alpha3"
    kind       = "VirtualMachineService"
    metadata = {
      name      = "terravcf-3nqm-lb"
      namespace = "greg01-b2y9g"
    }
    spec = {
      selector = {
        "terravcf-3nqm-vm" = "vm-lb-selector"
      }
      type = "LoadBalancer"
      ports = [
        {
          name       = "ssh"
          protocol   = "TCP"
          port       = 22
          targetPort = 22
        }
      ]
    }
  }
}

# ---------------------------------------------------------
# VirtualMachine 
# ---------------------------------------------------------
resource "kubernetes_manifest" "terravcf_vm" {
  manifest = {
    apiVersion = "vmoperator.vmware.com/v1alpha3"
    kind       = "VirtualMachine"
    metadata = {
      name      = "terravcf-3nqm-vm"
      namespace = "greg01-b2y9g"
      labels = {
        "vm-selector"    = "terravcf-3nqm-vm"
        "terravcf-3nqm-vm" = "vm-lb-selector"
      }
    }
    spec = {
      className    = "best-effort-small"
      imageName    = "vmi-81775fc9d7e0c99bd"
      storageClass = "vsan-default-storage-policy"
      powerState   = "PoweredOn"
      
      network = {
        interfaces = [
          {
            name = "eth0"
            network = {
              name = "subnet-s4cw"
              kind = "Subnet"
            }
          }
        ]
      }
      
      bootstrap = {
        cloudInit = {
          cloudConfig = {
            defaultUserEnabled = true
            ssh_pwauth         = true
            users = [
              {
                name = "gregory"
                passwd = {
                  name = "gregory-bootstrap-secret"
                  key  = "gregory-passwd"
                }
                lock_passwd = false
                sudo        = "ALL=(ALL) NOPASSWD:ALL"
              }
            ]
          }
        }
      }
    }
  }
}

# retrieve the generated name:
output "generated__name" {
  value = kubernetes_manifest.terravcf_vm.object.metadata.name
}