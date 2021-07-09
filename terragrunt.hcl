locals {
  # Read all variables defined in parent folders!
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl", "common.hcl"))

  # Extract variables for easy access
  entity            = local.common_vars.locals.entity
  unit              = local.common_vars.locals.unit
  tf_state_location = local.common_vars.locals.tf_state_location
  project_id        = local.common_vars.locals.project_id
}

remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket   = "${local.project_id}-tf-state"
    prefix   = path_relative_to_include()
    project  = local.project_id
    location = local.tf_state_location
  }
}

inputs = merge(
  local.common_vars.locals,
)
