include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/boldint/terraform-google-stack-poc//?ref=ready_for_terragrunt"
}

locals {
  # Read all variables defined in parent folders!
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl", "common.hcl"))

  # Extract variables for easy access
  environment       = split("/", path_relative_to_include())[0]
  location          = split("/", path_relative_to_include())[1]
  projectappservice = reverse(split("/", path_relative_to_include()))[0]
  project_id        = local.common_vars.locals.project_id
}

inputs = {
  projectappservice = local.projectappservice
  vpc_network       = "${local.project_id}-vpc1"
  environment       = local.environment

  # GKE
  gke_region                            = local.location
  gke_release_channel                   = "UNSPECIFIED"
  gke_enable_private_nodes              = true
  gke_enable_private_endpoint           = true
  gke_kubernetes_version                = "1.19"
  gke_regional                          = false
  gke_suffix                            = "gke"
  gke_subnetwork                        = "${local.project_id}-vpc1-gke1"
  gke_ip_range_pods                     = "${local.project_id}-vpc1-gke1-pods"
  gke_ip_range_services                 = "${local.project_id}-vpc1-gke1-services"
  gke_create_service_account            = false
  gke_zones                             = ["${local.location}-b"]
  gke_add_master_webhook_firewall_rules = true
  gke_firewall_inbound_ports            = ["15017", "443", "10250"]
  gke_http_load_balancing               = false
  gke_horizontal_pod_autoscaling        = false
  gke_network_policy                    = false
  gke_master_ipv4_cidr_block            = "10.0.0.0/28"
  gke_default_max_pods_per_node         = 55
  gke_node_pools = [
    {
      name               = "my-node-pool"
      machine_type       = "e2-standard-4"
      node_locations     = "europe-west1-b"
      min_count          = 3
      max_count          = 3
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS"
      preemptible        = false
      initial_node_count = 3
    },
  ]
  gke_asm_enable_all = true
  # Cloud SQL
  sql_suffix           = "sql"
  sql_database_version = "POSTGRES_12"
  sql_region           = local.location
  sql_zone             = "${local.location}-b"
  sql_tier             = "db-g1-small"
  sql_ip_configuration = {
    ipv4_enabled        = false # This flag pertains to Public IP
    require_ssl         = true
    private_network     = "projects/${local.project_id}/global/networks/${local.project_id}-vpc1"
    authorized_networks = []
  }
}
