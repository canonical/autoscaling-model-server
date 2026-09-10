# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

output "components" {
  description = "Map of the deployed applications"
  value = {
    envoy_ingress_k8s = juju_application.envoy_ingress_k8s
  }
}

output "provides" {
  description = "Map of endpoints provided by this component to other components (outbound relations)"
  value = {
    # Gateway metadata consumed by kserve-controller to program the gateway.
    envoy_ingress_gateway_metadata = {
      name     = juju_application.envoy_ingress_k8s.name
      endpoint = "gateway-metadata"
    }
    # HTTPRoute ingress for related applications.
    envoy_ingress_ingress = {
      name     = juju_application.envoy_ingress_k8s.name
      endpoint = "ingress"
    }
  }
}

output "requires" {
  description = "Map of endpoints required by this component from other components (inbound relations)"
  value = {
    # TLS certificates for the Gateway HTTPS listeners (optional).
    envoy_ingress_certificates = {
      name     = juju_application.envoy_ingress_k8s.name
      endpoint = "certificates"
    }
    # External authentication provider for the ingress gateway (optional).
    envoy_ingress_forward_auth = {
      name     = juju_application.envoy_ingress_k8s.name
      endpoint = "forward-auth"
    }
  }
}
