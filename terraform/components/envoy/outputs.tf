# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

output "components" {
  description = "Map of the deployed Envoy Gateway applications"
  value = {
    envoy_controller_k8s    = juju_application.envoy_controller_k8s
    envoy_ai_controller_k8s = juju_application.envoy_ai_controller_k8s
  }
}

output "provides" {
  description = "Map of endpoints provided by this component to other components (outbound relations)"
  value = {
    # Prometheus scrape targets and Grafana dashboards for COS integration.
    envoy_controller_metrics_endpoint = {
      name     = juju_application.envoy_controller_k8s.name
      endpoint = "metrics-endpoint"
    }
    envoy_controller_grafana_dashboard = {
      name     = juju_application.envoy_controller_k8s.name
      endpoint = "grafana-dashboard"
    }
    envoy_ai_controller_metrics_endpoint = {
      name     = juju_application.envoy_ai_controller_k8s.name
      endpoint = "metrics-endpoint"
    }
    envoy_ai_controller_grafana_dashboard = {
      name     = juju_application.envoy_ai_controller_k8s.name
      endpoint = "grafana-dashboard"
    }
  }
}

output "requires" {
  description = "Map of endpoints required by this component from other components (inbound relations)"
  value = {
    # OTLP metrics export for the Envoy Gateway and AI Gateway controllers.
    envoy_controller_otlp = {
      name     = juju_application.envoy_controller_k8s.name
      endpoint = "otlp"
    }
    envoy_ai_controller_otlp = {
      name     = juju_application.envoy_ai_controller_k8s.name
      endpoint = "otlp"
    }
    # TLS certificates for the ExtProc admission webhook (mandatory).
    envoy_ai_controller_certificates = {
      name     = juju_application.envoy_ai_controller_k8s.name
      endpoint = "certificates"
    }
  }
}
