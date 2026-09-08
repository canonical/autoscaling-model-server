# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

resource "juju_model" "llm" {
  count = var.create_model ? 1 : 0
  name  = var.model_name

  # Only set the cloud when provided; otherwise Juju uses its default cloud.
  dynamic "cloud" {
    for_each = var.cloud != null ? [var.cloud] : []
    content {
      name = cloud.value
    }
  }
}

# Envoy Gateway control plane (controller + AI Gateway controller).
module "envoy" {
  source = "../../components/envoy"

  model_uuid = local.model_uuid

  envoy_controller_k8s = {
    channel  = var.envoy_channel
    revision = var.envoy_controller_k8s_revision
  }
  envoy_ai_controller_k8s = {
    channel  = var.envoy_channel
    revision = var.envoy_ai_controller_k8s_revision
  }
}

# Envoy Gateway ingress (user-facing Gateway API resources). Reconciled by the
# envoy control plane through the Gateway API CRDs (no direct Juju relation).
module "envoy_ingress" {
  source = "../../components/envoy-ingress"

  model_uuid = local.model_uuid

  envoy_ingress_k8s = {
    channel  = var.envoy_channel
    revision = var.envoy_ingress_k8s_revision
  }
}

# TLS certificates for the Envoy AI Gateway ExtProc admission webhook, handled at
# the product level (matching kubeflow) and wired into the envoy component.
resource "juju_application" "self_signed_certificates" {
  model_uuid = local.model_uuid
  name       = "self-signed-certificates"

  charm {
    name     = "self-signed-certificates"
    channel  = var.self_signed_certificates_channel
    revision = var.self_signed_certificates_revision
  }

  config = var.self_signed_certificates_config
  trust  = true
  units  = 1
}

resource "juju_integration" "envoy_ai_controller_certificates" {
  model_uuid = local.model_uuid

  application {
    name     = juju_application.self_signed_certificates.name
    endpoint = "certificates"
  }

  application {
    name     = module.envoy.requires.envoy_ai_controller_certificates.name
    endpoint = module.envoy.requires.envoy_ai_controller_certificates.endpoint
  }
}

# KServe LLM serving control plane. gateway-metadata is wired to the Envoy
# ingress gateway so LLMInferenceService routes are exposed.
module "kserve_llm" {
  source     = "../../components/kserve-llm"
  depends_on = [module.envoy_ingress]

  model_uuid = local.model_uuid

  kserve_controller = {
    channel  = var.kserve_channel
    revision = var.kserve_controller_revision
    config   = var.kserve_controller_config
  }
  kserve_llmisvc = {
    channel  = var.kserve_channel
    revision = var.kserve_llmisvc_revision
  }

  gateway_metadata = {
    kind     = "endpoint"
    name     = module.envoy_ingress.provides.envoy_ingress_gateway_metadata.name
    endpoint = module.envoy_ingress.provides.envoy_ingress_gateway_metadata.endpoint
  }
}

# LeaderWorkerSet controller for multi-node inference workers.
module "lws_controller" {
  source = "../../components/lws-controller"

  model_uuid = local.model_uuid

  lws_controller = {
    channel  = var.lws_controller_channel
    revision = var.lws_controller_revision
  }
}

# lws-controller feeds LeaderWorkerSet configuration to kserve-llmisvc.
resource "juju_integration" "kserve_llmisvc_lws_controller" {
  model_uuid = local.model_uuid

  application {
    name     = module.lws_controller.provides.lws_controller_sync.name
    endpoint = module.lws_controller.provides.lws_controller_sync.endpoint
  }

  application {
    name     = module.kserve_llm.requires.kserve_llmisvc_lws_controller.name
    endpoint = module.kserve_llm.requires.kserve_llmisvc_lws_controller.endpoint
  }
}

# Observability: opentelemetry-collector-k8s aggregating the KServe LLM charms'
# telemetry and forwarding it to a cross-model COS stack.
module "observability" {
  count      = var.enable_observability ? 1 : 0
  source     = "../../components/observability"
  depends_on = [module.kserve_llm]

  model_uuid = local.model_uuid

  dashboards_offer = var.dashboards_offer
  logging_offer    = var.logging_offer
  metrics_offer    = var.metrics_offer

  opentelemetry_collector_k8s = {
    revision = var.opentelemetry_collector_k8s_revision
    config   = var.opentelemetry_collector_k8s_config
  }

  kserve_controller_metrics_endpoint = module.kserve_llm.provides.kserve_controller_metrics_endpoint
  kserve_llmisvc_metrics_endpoint    = module.kserve_llm.provides.kserve_llmisvc_metrics_endpoint
  kserve_llmisvc_grafana_dashboard   = module.kserve_llm.provides.kserve_llmisvc_grafana_dashboard
  kserve_controller_logging          = module.kserve_llm.requires.kserve_controller_logging
  kserve_llmisvc_logging             = module.kserve_llm.requires.kserve_llmisvc_logging
  lws_controller_logging             = module.lws_controller.requires.lws_controller_logging
}
