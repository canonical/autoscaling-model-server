# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

variable "model_uuid" {
  description = "UUID of the pre-created Juju model to deploy the LLM serving stack into"
  type        = string
  nullable    = false
}

variable "create_cos_model" {
  description = "Create a Juju model for the COS deployment"
  type        = bool
  default     = true
}

variable "cos_model_uuid" {
  description = "UUID of an existing Juju model to deploy COS into (required when create_cos_model is false)"
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.create_cos_model || var.cos_model_uuid != null
    error_message = "cos_model_uuid must be provided when create_cos_model is false."
  }
}

variable "cos_model_name" {
  description = "Name of the Juju model to create for COS"
  type        = string
  default     = "cos"
}

variable "cos_channel" {
  description = "Channel to deploy COS Lite applications from"
  type        = string
  default     = "2/stable"
}
