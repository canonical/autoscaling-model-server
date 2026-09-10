# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

variable "model_uuid" {
  description = "UUID of the Juju model where envoy-ingress-k8s is deployed"
  type        = string
  nullable    = false
}

variable "envoy_ingress_k8s" {
  description = "Configuration for the envoy-ingress-k8s application (user-facing Gateway API resources)"
  type = object({
    app_name    = optional(string, "envoy-ingress-k8s")
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
