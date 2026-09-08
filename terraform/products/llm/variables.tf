# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

variable "create_model" {
  description = "Whether to create the Juju model or reuse an existing one (identified by var.model_uuid)"
  type        = bool
  default     = true
}

variable "model_name" {
  description = "Name of the Juju model to create when var.create_model is true"
  type        = string
  default     = "kserve-llm"
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

# --- Per-charm channel overrides -------------------------------------------

variable "envoy_channel" {
  description = "Charm channel for the Envoy Gateway stack (controller, ai-controller, ingress)"
  type        = string
  default     = "latest/edge"
}

variable "self_signed_certificates_channel" {
  description = "Charm channel for self-signed-certificates"
  type        = string
  default     = "latest/stable"
}

variable "kserve_channel" {
  description = "Charm channel for kserve-controller and kserve-llmisvc"
  type        = string
  default     = "latest/edge"
}

variable "lws_controller_channel" {
  description = "Charm channel for lws-controller"
  type        = string
  default     = "latest/edge"
}

# --- Per-charm revision overrides ------------------------------------------

variable "envoy_controller_k8s_revision" {
  description = "Charm revision for envoy-controller-k8s"
  type        = number
  default     = null
}

variable "envoy_ai_controller_k8s_revision" {
  description = "Charm revision for envoy-ai-controller-k8s"
  type        = number
  default     = null
}

variable "envoy_ingress_k8s_revision" {
  description = "Charm revision for envoy-ingress-k8s"
  type        = number
  default     = null
}

variable "self_signed_certificates_revision" {
  description = "Charm revision for self-signed-certificates"
  type        = number
  default     = null
}

variable "self_signed_certificates_config" {
  description = "Extra config for self-signed-certificates"
  type        = map(string)
  default     = {}
}

variable "kserve_controller_revision" {
  description = "Charm revision for kserve-controller"
  type        = number
  default     = null
}

variable "kserve_llmisvc_revision" {
  description = "Charm revision for kserve-llmisvc"
  type        = number
  default     = null
}

variable "lws_controller_revision" {
  description = "Charm revision for lws-controller"
  type        = number
  default     = null
}

# --- Per-charm config overrides --------------------------------------------

variable "kserve_controller_config" {
  description = "Extra config for kserve-controller (merged over the defaults)"
  type        = map(string)
  default     = {}
}

# --- Observability (COS) ----------------------------------------------------

variable "enable_observability" {
  description = "Deploy an opentelemetry-collector-k8s and wire the KServe LLM charms to a cross-model COS stack. Requires the three *_offer URLs."
  type        = bool
  default     = false
}

variable "dashboards_offer" {
  description = "URL of the `grafana_dashboard` interface offer from the COS stack (required when enable_observability is true)"
  type        = string
  nullable    = true
  default     = null
}

variable "logging_offer" {
  description = "URL of the `loki_push_api` interface offer from the COS stack (required when enable_observability is true)"
  type        = string
  nullable    = true
  default     = null
}

variable "metrics_offer" {
  description = "URL of the `prometheus_remote_write` interface offer from the COS stack (required when enable_observability is true)"
  type        = string
  nullable    = true
  default     = null
}

variable "opentelemetry_collector_k8s_revision" {
  description = "Charm revision for opentelemetry-collector-k8s"
  type        = number
  default     = null
}

variable "opentelemetry_collector_k8s_config" {
  description = "Extra config for opentelemetry-collector-k8s"
  type        = map(string)
  default     = {}
}
