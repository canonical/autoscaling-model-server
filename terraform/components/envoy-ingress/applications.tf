# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# Envoy Gateway ingress. Manages user-facing Gateway API resources (Gateway,
# HTTPRoute, SecurityPolicy) and publishes gateway metadata to downstream
# consumers such as kserve-controller. Reconciled by the Envoy Gateway control
# plane (envoy component) via the Gateway API CRDs.
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
