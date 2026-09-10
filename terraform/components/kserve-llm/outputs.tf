# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

output "components" {
  description = "Map of the deployed KServe LLM serving applications"
  value = {
    kserve_controller = juju_application.kserve_controller
    kserve_llmisvc    = juju_application.kserve_llmisvc
  }
}

output "provides" {
  description = "Map of endpoints provided by this component to other components (outbound relations)"
  value = {
    # Consumed by an end-user llm-integrator deployment.
    kserve_llmisvc_sync = {
      name     = juju_application.kserve_llmisvc.name
      endpoint = "kserve-llmisvc"
    }
    # Prometheus scrape targets and Grafana dashboard for COS integration.
    kserve_controller_metrics_endpoint = {
      name     = juju_application.kserve_controller.name
      endpoint = "metrics-endpoint"
    }
    kserve_llmisvc_metrics_endpoint = {
      name     = juju_application.kserve_llmisvc.name
      endpoint = "metrics-endpoint"
    }
    kserve_llmisvc_grafana_dashboard = {
      name     = juju_application.kserve_llmisvc.name
      endpoint = "grafana-dashboard"
    }
  }
}

output "requires" {
  description = "Map of endpoints required by this component from other components (inbound relations)"
  value = {
    # gateway-metadata from the ingress gateway (also wired via var.gateway_metadata).
    kserve_controller_gateway_metadata = {
      name     = juju_application.kserve_controller.name
      endpoint = "gateway-metadata"
    }
    # Loki logging endpoints for COS integration.
    kserve_controller_logging = {
      name     = juju_application.kserve_controller.name
      endpoint = "logging"
    }
    kserve_llmisvc_logging = {
      name     = juju_application.kserve_llmisvc.name
      endpoint = "logging"
    }
    # kserve-llmisvc consumes lws-controller from the lws-controller component.
    kserve_llmisvc_lws_controller = {
      name     = juju_application.kserve_llmisvc.name
      endpoint = "lws-controller"
    }
  }
}
