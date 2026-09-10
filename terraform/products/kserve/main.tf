# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

resource "juju_model" "kserve" {
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

# Istio service mesh in sidecar mode (istio-pilot + istio-ingressgateway),
# used by knative mode. Reuses the Charmed Kubeflow Solutions component,
# pinned to a commit because the upstream repository has no tags. Terraform does
# not allow variable interpolation in a module source, so the ref is inline.
module "istio" {
  count  = local.knative ? 1 : 0
  source = "git::https://github.com/canonical/charmed-kubeflow-solutions//terraform/components/istio-sidecar?ref=7cf3c85bde844a060ec985c1b3aa97c57d3fa3fc"

  model_uuid = local.model_uuid

  istio_pilot = {
    channel  = var.istio_channel
    revision = var.istio_pilot_revision
    config   = { default-gateway = var.istio_default_gateway }
  }
  istio_ingressgateway = {
    channel  = var.istio_channel
    revision = var.istio_ingressgateway_revision
    config   = { kind = "ingress" }
  }
}

# Istio ambient mesh (istio-k8s + istio-ingress-k8s + istio-beacon-k8s), used by
# standard mode. Reuses the Charmed Kubeflow Solutions istio-ambient-dex
# component (the auth wiring is product-level in kubeflow, so this component
# itself is auth-free). Provides gateway-metadata (Gateway API) and service-mesh.
module "istio_ambient" {
  count  = local.standard ? 1 : 0
  source = "git::https://github.com/canonical/charmed-kubeflow-solutions//terraform/components/istio-ambient-dex?ref=7cf3c85bde844a060ec985c1b3aa97c57d3fa3fc"

  model_uuid = local.model_uuid

  istio_k8s = {
    channel  = var.istio_k8s_channel
    revision = var.istio_k8s_revision
  }
  istio_ingress_k8s = {
    channel  = var.istio_k8s_channel
    revision = var.istio_ingress_k8s_revision
  }
  istio_beacon_k8s = {
    channel  = var.istio_k8s_channel
    revision = var.istio_beacon_k8s_revision
  }
}

# KServe control plane. Reuses the Charmed Kubeflow Solutions component for both
# modes: Knative is deployed only when gateway_info is set (knative/sidecar);
# standard mode passes gateway_metadata + service_mesh (ambient) instead, so no
# Knative is deployed. This product intentionally omits the LLM serving charms.
module "kserve" {
  source     = "git::https://github.com/canonical/charmed-kubeflow-solutions//terraform/components/kserve?ref=7cf3c85bde844a060ec985c1b3aa97c57d3fa3fc"
  depends_on = [module.istio, module.istio_ambient]

  model_uuid = local.model_uuid

  # knative: istio-pilot gateway-info (also gates Knative deployment).
  gateway_info = local.knative ? {
    kind     = "endpoint"
    name     = module.istio[0].provides.istio_pilot_gateway_info.name
    endpoint = module.istio[0].provides.istio_pilot_gateway_info.endpoint
  } : null

  # standard: ambient istio-ingress-k8s gateway (Gateway API) + beacon mesh.
  gateway_metadata = local.standard ? {
    kind     = "endpoint"
    name     = module.istio_ambient[0].provides.istio_ingress_k8s_gateway_metadata.name
    endpoint = module.istio_ambient[0].provides.istio_ingress_k8s_gateway_metadata.endpoint
  } : null

  service_mesh = local.standard ? {
    kind     = "endpoint"
    name     = module.istio_ambient[0].provides.istio_beacon_k8s_service_mesh.name
    endpoint = module.istio_ambient[0].provides.istio_beacon_k8s_service_mesh.endpoint
  } : null

  kserve_controller = {
    channel  = var.kserve_channel
    revision = var.kserve_controller_revision
    # deployment-mode is reserved (coupled to the istio topology), so merge it
    # last — callers must not be able to override it into an inconsistent state.
    config = merge(var.kserve_controller_config, { "deployment-mode" = var.kserve_mode })
  }

  knative_operator = {
    channel  = var.knative_channel
    revision = var.knative_operator_revision
  }

  knative_serving = {
    channel  = var.knative_channel
    revision = var.knative_serving_revision
    config = {
      "istio.gateway.namespace" = var.model_name
      "istio.gateway.name"      = var.istio_default_gateway
    }
  }

  knative_eventing = {
    channel  = var.knative_channel
    revision = var.knative_eventing_revision
  }
}
