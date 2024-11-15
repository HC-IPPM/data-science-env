variable "project_id" {
  description = "id of the project. project must be created before running this script"
  type = string
  nullable = false

  validation {
    condition     = length(var.project_id) > 4 && signum(substr(var.project_id, 0, 4) == "phx-" + substr(var.project_id, 0, 4) == "hcx-") ? 1:0
    error_message = "The project id value must be a valid id, starting with \"phx-\" or \"hcx-\"."
  }
}

variable "region" {
  description = "region of the project. project must be created before running this script"
  type = string
  nullable = false
}

variable "zone" {
  description = "zone of a region"
  type = string
  nullable = false
}

variable "dataplex_option" {
  description = "option to enable or disable dataplex option"
  type = bool
  default = false
  
}