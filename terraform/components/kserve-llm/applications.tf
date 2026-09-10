# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# KServe Controller application (standard deployment mode for LLM serving).
resource "juju_application" "kserve_controller" {
  charm {
    name     = "kserve-controller"
    channel  = var.kserve_controller.channel
    revision = var.kserve_controller.revision
  }

  model_uuid  = var.model_uuid
  name        = var.kserve_controller.app_name
  units       = var.kserve_controller.units
  trust       = var.kserve_controller.trust
  constraints = var.kserve_controller.constraints
  # Force standard mode after caller config: this component deploys no Knative.
  config    = merge(var.kserve_controller.config, { "deployment-mode" = "standard" })
  resources = var.kserve_controller.resources
}

# KServe LLMISVC controller (reconciles LLMInferenceService resources).
resource "juju_application" "kserve_llmisvc" {
  charm {
    name     = "kserve-llmisvc"
    channel  = var.kserve_llmisvc.channel
    revision = var.kserve_llmisvc.revision
  }

  model_uuid  = var.model_uuid
  name        = var.kserve_llmisvc.app_name
  units       = var.kserve_llmisvc.units
  trust       = var.kserve_llmisvc.trust
  constraints = var.kserve_llmisvc.constraints
  config      = var.kserve_llmisvc.config
  resources   = var.kserve_llmisvc.resources
}
