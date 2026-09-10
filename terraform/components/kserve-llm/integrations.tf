# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# kserve-controller feeds shared serving configuration to kserve-llmisvc.
resource "juju_integration" "kserve_llmisvc_kserve_controller" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.kserve_controller.name
    endpoint = "kserve-controller"
  }

  application {
    name     = juju_application.kserve_llmisvc.name
    endpoint = "kserve-controller"
  }
}

# gateway-metadata: kserve-controller programs the ingress gateway (Envoy or
# Istio) so LLMInferenceService routes are exposed. Supports same-model
# endpoint or cross-model offer.
resource "juju_integration" "kserve_controller_gateway_metadata" {
  count      = var.gateway_metadata != null ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = juju_application.kserve_controller.name
    endpoint = "gateway-metadata"
  }

  application {
    name      = var.gateway_metadata.kind == "endpoint" ? var.gateway_metadata.name : null
    endpoint  = var.gateway_metadata.kind == "endpoint" ? var.gateway_metadata.endpoint : null
    offer_url = var.gateway_metadata.kind == "offer" ? var.gateway_metadata.url : null
  }
}
