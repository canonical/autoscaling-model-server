# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

variable "model_uuid" {
  description = "UUID of the Juju model where the observability collector is deployed"
  type        = string
  nullable    = false
}

variable "opentelemetry_collector_k8s" {
  description = "Configuration for the opentelemetry-collector-k8s application"
  type = object({
    channel      = optional(string, "2/stable")
    revision     = optional(number)
    units        = optional(number, 1)
    trust        = optional(bool, true)
    constraints  = optional(string, "arch=amd64")
    config       = optional(map(string), {})
    resources    = optional(map(string), {})
    storage_size = optional(string, "10G")
  })
  default = {}
}

# ---------------------------------------------------------------------------
# Cross-model COS offer URLs
# ---------------------------------------------------------------------------

variable "dashboards_offer" {
  description = "URL of the `grafana_dashboard` interface offer from the COS stack."
  type        = string
  nullable    = false
}

variable "logging_offer" {
  description = "URL of the `loki_push_api` interface offer from the COS stack."
  type        = string
  nullable    = false
}

variable "metrics_offer" {
  description = "URL of the `prometheus_remote_write` interface offer from the COS stack."
  type        = string
  nullable    = false
}

# ---------------------------------------------------------------------------
# Metrics endpoints (prometheus_scrape) provided by the observed charms
# ---------------------------------------------------------------------------

variable "kserve_controller_metrics_endpoint" {
  description = "metrics-endpoint (prometheus_scrape) provided by kserve-controller"
  type        = object({ name = string, endpoint = string })
  nullable    = true
  default     = null
}

variable "kserve_llmisvc_metrics_endpoint" {
  description = "metrics-endpoint (prometheus_scrape) provided by kserve-llmisvc"
  type        = object({ name = string, endpoint = string })
  nullable    = true
  default     = null
}

# ---------------------------------------------------------------------------
# Grafana dashboard endpoints (grafana_dashboard) provided by the observed charms
# ---------------------------------------------------------------------------

variable "kserve_llmisvc_grafana_dashboard" {
  description = "grafana-dashboard (grafana_dashboard) provided by kserve-llmisvc"
  type        = object({ name = string, endpoint = string })
  nullable    = true
  default     = null
}

# ---------------------------------------------------------------------------
# Logging endpoints (loki_push_api) required by the observed charms
# ---------------------------------------------------------------------------

variable "kserve_controller_logging" {
  description = "logging (loki_push_api) required by kserve-controller"
  type        = object({ name = string, endpoint = string })
  nullable    = true
  default     = null
}

variable "kserve_llmisvc_logging" {
  description = "logging (loki_push_api) required by kserve-llmisvc"
  type        = object({ name = string, endpoint = string })
  nullable    = true
  default     = null
}

variable "lws_controller_logging" {
  description = "logging (loki_push_api) required by lws-controller"
  type        = object({ name = string, endpoint = string })
  nullable    = true
  default     = null
}
