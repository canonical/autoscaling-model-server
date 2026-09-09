# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

variable "create_model" {
  description = "Whether to create the Juju model or reuse an existing one (identified by var.model_uuid)"
  type        = bool
  default     = true
}

variable "model_name" {
  description = "Name of the Juju model. Required (also when reusing an existing model) because it is used to configure Knative's ingress gateway namespace."
  type        = string
  default     = "kserve"
}

variable "model_uuid" {
  description = "UUID of an existing Juju model to deploy into when var.create_model is false"
  type        = string
  nullable    = true
  default     = null
}

variable "cloud" {
  description = "Kubernetes cloud to create the model on when var.create_model is true. Leave null to use Juju's default cloud."
  type        = string
  nullable    = true
  default     = null
}

variable "kserve_mode" {
  description = "KServe deployment mode, matching kserve-controller's deployment-mode config: 'knative' pairs with the Istio sidecar gateway and deploys Knative; 'standard' (RawDeployment) pairs with the ambient Istio gateway and deploys no Knative."
  type        = string
  default     = "knative"

  validation {
    condition     = contains(["knative", "standard"], var.kserve_mode)
    error_message = "kserve_mode must be either \"knative\" or \"standard\"."
  }
}

variable "istio_default_gateway" {
  description = "Name of the Istio gateway shared by istio-pilot and Knative Serving"
  type        = string
  default     = "kserve-gateway"
}

# --- Per-charm channel overrides -------------------------------------------

variable "istio_channel" {
  description = "Charm channel for istio-pilot and istio-ingressgateway (knative / sidecar mode)"
  type        = string
  default     = "1.28/stable"
}

variable "istio_k8s_channel" {
  description = "Charm channel for the ambient Istio charms istio-k8s, istio-ingress-k8s and istio-beacon-k8s (standard mode)"
  type        = string
  default     = "2/stable"
}

variable "knative_channel" {
  description = "Charm channel for the Knative charms"
  type        = string
  default     = "1.16/stable"
}

variable "kserve_channel" {
  description = "Charm channel for kserve-controller"
  type        = string
  default     = "latest/edge"
}

# --- Per-charm revision overrides ------------------------------------------

variable "istio_pilot_revision" {
  description = "Charm revision for istio-pilot"
  type        = number
  default     = null
}

variable "istio_ingressgateway_revision" {
  description = "Charm revision for istio-ingressgateway"
  type        = number
  default     = null
}

variable "istio_k8s_revision" {
  description = "Charm revision for istio-k8s (standard mode)"
  type        = number
  default     = null
}

variable "istio_ingress_k8s_revision" {
  description = "Charm revision for istio-ingress-k8s (standard mode)"
  type        = number
  default     = null
}

variable "istio_beacon_k8s_revision" {
  description = "Charm revision for istio-beacon-k8s (standard mode)"
  type        = number
  default     = null
}

variable "knative_operator_revision" {
  description = "Charm revision for knative-operator"
  type        = number
  default     = null
}

variable "knative_serving_revision" {
  description = "Charm revision for knative-serving"
  type        = number
  default     = null
}

variable "knative_eventing_revision" {
  description = "Charm revision for knative-eventing"
  type        = number
  default     = null
}

variable "kserve_controller_revision" {
  description = "Charm revision for kserve-controller"
  type        = number
  default     = null
}

# --- Per-charm config overrides --------------------------------------------

variable "kserve_controller_config" {
  description = "Extra config for kserve-controller (merged over the defaults)"
  type        = map(string)
  default     = {}
}
