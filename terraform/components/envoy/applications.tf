# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# Envoy Gateway control plane. Owns the Gateway API / Gateway Inference
# Extension CRDs and reconciles the Envoy Proxy data plane.
resource "juju_application" "envoy_controller_k8s" {
  charm {
    name     = "envoy-controller-k8s"
    channel  = var.envoy_controller_k8s.channel
    revision = var.envoy_controller_k8s.revision
  }

  model_uuid  = var.model_uuid
  name        = var.envoy_controller_k8s.app_name
  units       = var.envoy_controller_k8s.units
  trust       = var.envoy_controller_k8s.trust
  constraints = var.envoy_controller_k8s.constraints
  config      = var.envoy_controller_k8s.config
  resources   = var.envoy_controller_k8s.resources
}

# Envoy AI Gateway control plane. Serves the Extension Server protocol so the
# Envoy Gateway control plane can delegate AI-specific xDS fine-tuning to it.
resource "juju_application" "envoy_ai_controller_k8s" {
  charm {
    name     = "envoy-ai-controller-k8s"
    channel  = var.envoy_ai_controller_k8s.channel
    revision = var.envoy_ai_controller_k8s.revision
  }

  model_uuid  = var.model_uuid
  name        = var.envoy_ai_controller_k8s.app_name
  units       = var.envoy_ai_controller_k8s.units
  trust       = var.envoy_ai_controller_k8s.trust
  constraints = var.envoy_ai_controller_k8s.constraints
  config      = var.envoy_ai_controller_k8s.config
  resources   = var.envoy_ai_controller_k8s.resources
}

# Envoy Gateway ingress. Manages user-facing Gateway API resources (Gateway,
# HTTPRoute, SecurityPolicy) and publishes gateway metadata to downstream
# consumers such as kserve-controller.
resource "juju_application" "envoy_ingress_k8s" {
  charm {
    name     = "envoy-ingress-k8s"
    channel  = var.envoy_ingress_k8s.channel
    revision = var.envoy_ingress_k8s.revision
  }

  model_uuid  = var.model_uuid
  name        = var.envoy_ingress_k8s.app_name
  units       = var.envoy_ingress_k8s.units
  trust       = var.envoy_ingress_k8s.trust
  constraints = var.envoy_ingress_k8s.constraints
  config      = var.envoy_ingress_k8s.config
  resources   = var.envoy_ingress_k8s.resources
}
