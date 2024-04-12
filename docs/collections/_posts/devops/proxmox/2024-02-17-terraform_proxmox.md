---
layout: post
title: Using Terraform Provider with Proxmox
date: 2024-02-16
summary: Covers setting up the terraform provider for proxmox to automate virtual machine deployment.
categories: guides
---

## Guide results

Be able to deploy virtual machines to proxmox server via terraform.

## Prerequisites

Have a proxmox machine running.

## Begin

First we need to install terraform. See [here](https://developer.hashicorp.com/terraform/install) for operating system dependent steps. Here is how you can do it on `ubuntu/debian`.

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

Now, we need to set up the API tokens for proxmox. Go to the UI->Datacenter->Permissions->API Tokens->Add

- Unselect the `Privilege Seperation` box.
- Personally, I just used the `root@pam` user, however you can create a seperate one with specific scope if needed.
- Put in something like `terraform2` for the Token ID.

Make sure you dont exit out before using the token, or youll have to remake one.

Now, make a new file called provider.tf with the following contents,

```tf
# This is from the provider here -> https://registry.terraform.io/providers/Telmate/proxmox/latest
terraform {
  required_version = ">= 0.12"

  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

# This is from the secrets file we will make
variable "proxmox_api_url" {
  type = string
}

# This is from the secrets file we will make
variable "proxmox_api_token_id" {
  type = string
  sensitive = true
}

# This is from the secrets file we will make
variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}

# This is just linking the secrets above.
provider "proxmox" {
  pm_api_url = var.proxmox_api_url
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret

  # If you have a self-signed certificate, disable verification
  pm_tls_insecure = true
}
```

Now we need to create those secrets. Create a file `credentials.auto.tfvars` with the following content,

```tf
proxmox_api_url = "https://MachineIP/api2/json"
proxmox_api_token_id = "yourTokenID"
proxmox_api_token_secret = "yourToken"
```

Finally, we can initiate the project with terraform, (Ensure you are in the same directory)

```bash
terraform init
```
