terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "high_of_busy_threads_on_tomcat_host_test" {
  source    = "./modules/high_of_busy_threads_on_tomcat_host_test"

  providers = {
    shoreline = shoreline
  }
}