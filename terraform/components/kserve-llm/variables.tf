# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

variable "model_uuid" {
  description = "UUID of the Juju model where the KServe LLM serving stack is deployed"
  type        = string
  nullable    = false
}

variable "kserve_controller" {
  description = "Configuration for the kserve-controller application. deployment-mode is always forced to standard (this component ships no Knative)."
  type = object({
    app_name    = optional(string, "kserve-controller")
    channel     = optional(string, "latest/edge")
    revision    = optional(number)
    units       = optional(number, 1)
    trust       = optional(bool, true)
    constraints = optional(string, "arch=amd64")
    config      = optional(map(string), {})
    resources   = optional(map(string), {})
  })
  default = {}
}

variable "kserve_llmisvc" {
  description = "Configuration for the kserve-llmisvc application"
  type = object({
    app_name    = optional(string, "kserve-llmisvc")
    channel     = optional(string, "latest/edge")
    revision    = optional(number)
    units       = optional(number, 1)
    trust       = optional(bool, true)
    constraints = optional(string, "arch=amd64")
    config      = optional(map(string), {})
    resources   = optional(map(string), {})
  })
  default = {}
}

variable "lws_controller" {
  description = "Configuration for the lws-controller application"
  type = object({
    app_name    = optional(string, "lws-controller")
    channel     = optional(string, "latest/edge")
    revision    = optional(number)
    units       = optional(number, 1)
    trust       = optional(bool, true)
    constraints = optional(string, "arch=amd64")
    config      = optional(map(string), {})
    resources   = optional(map(string), {})
  })
  default = {}
}

variable "gateway_metadata" {
  description = <<-EOT
    Gateway metadata endpoint consumed by kserve-controller (from an Envoy or
    Istio ingress gateway). Supports a same-model endpoint or a cross-model
    offer. When null, kserve-controller is deployed without a gateway relation.
  EOT
  type = object({
    kind     = string
    name     = optional(string)
    endpoint = optional(string)
    url      = optional(string)
  })
  nullable = true
  default  = null

  validation {
    condition     = var.gateway_metadata == null || contains(["endpoint", "offer"], var.gateway_metadata.kind)
    error_message = "gateway_metadata.kind must be either \"endpoint\" or \"offer\"."
  }

  validation {
    condition     = var.gateway_metadata == null || var.gateway_metadata.kind != "endpoint" || (var.gateway_metadata.name != null && var.gateway_metadata.name != "" && var.gateway_metadata.endpoint != null && var.gateway_metadata.endpoint != "")
    error_message = "Both 'name' and 'endpoint' must be provided for an in-model (kind=endpoint) gateway_metadata integration."
  }

  validation {
    condition     = var.gateway_metadata == null || var.gateway_metadata.kind != "offer" || (var.gateway_metadata.url != null && var.gateway_metadata.url != "")
    error_message = "'url' must be provided for a cross-model (kind=offer) gateway_metadata integration."
  }
}
