//// main.tf

# ---------------------------------------------------------
# Subnet
# ---------------------------------------------------------
resource "kubernetes_manifest" "vcfcli_subnet" {
  manifest = {
    apiVersion = "crd.nsx.vmware.com/v1alpha1"
    kind       = "Subnet"
    metadata = {
      name      = "${var.name_prefix}-subnet"
      namespace = var.namespace
    }
    spec = {
      accessMode = "PrivateTGW"
      subnetDHCPConfig = {
        mode = "DHCPServer"
      }
      ipv4SubnetSize = 16
      ipAddresses    = []
    }
  }
}

# ---------------------------------------------------------
# VirtualMachineService LoadBalancer
# ---------------------------------------------------------
resource "kubernetes_manifest" "vcfcli_lb" {
  manifest = {
    apiVersion = "vmoperator.vmware.com/v1alpha3"
    kind       = "VirtualMachineService"
    metadata = {
      name      = "${var.name_prefix}-lb"
      namespace = var.namespace
    }
    spec = {
      selector = {
        "${var.name_prefix}-vm" = "vm-lb-selector"
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
resource "kubernetes_manifest" "vcfcli_vm" {
  # Ensure the subnet is created before the VM tries to attach to it
  depends_on = [kubernetes_manifest.vcfcli_subnet]

  manifest = {
    apiVersion = "vmoperator.vmware.com/v1alpha3"
    kind       = "VirtualMachine"
    metadata = {
      name      = "${var.name_prefix}-vm"
      namespace = var.namespace
      labels = {
        "vm-selector"           = "${var.name_prefix}-vm"
        "${var.name_prefix}-vm" = "vm-lb-selector"
      }
    }
    spec = {
      className    = "best-effort-small"
      imageName    = "vmi-81775fc9d7e0c99bd" # noble-server-cloudimg-amd64
      storageClass = "vsan-default-storage-policy"
      powerState   = "PoweredOn"
      
      network = {
        interfaces = [
          {
            name = "eth0"
            network = {
              name = "${var.name_prefix}-subnet"
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