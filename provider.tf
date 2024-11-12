variable "pm_api_url" {
  type = string
}

#variable "pm_api_token_id" {
#  type = string
#}

#variable "pm_apit_token_secret" {
#  type = string
#}

terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

provider "vault" {
  address = "http://172.23.26.133:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "e1706f58-0c63-9c11-6f04-4f4721a206df"
      secret_id = "5294a0e4-431d-1a8b-011a-6eda9378adbe"
    }
  }
}


data "vault_kv_secret_v2" "test1" {
  mount = "kv-v2" 
  name  = "proxmox" 
}


provider "proxmox" {
  pm_api_url = var.pm_api_url
  pm_api_token_id = data.vault_kv_secret_v2.test1.data["pm_api_token_id"]
  pm_api_token_secret = data.vault_kv_secret_v2.test1.data["pm_api_token_secret"]
  pm_log_enable = true
  pm_log_file = "tflog.log"
  pm_debug = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = " "
  }
}