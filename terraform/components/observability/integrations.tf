# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# ---------------------------------------------------------------------------
# Cross-model COS offer data sources
# ---------------------------------------------------------------------------

data "juju_offer" "grafana_dashboards" {
  url = var.dashboards_offer
}

data "juju_offer" "loki_logging" {
  url = var.logging_offer
}

data "juju_offer" "prometheus_receive_remote_write" {
  url = var.metrics_offer
}

# ---------------------------------------------------------------------------
# Cross-model COS integrations (collector -> COS)
# ---------------------------------------------------------------------------

resource "juju_integration" "opentelemetry_collector_k8s_grafana_dashboards" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.opentelemetry_collector_k8s.name
    endpoint = "grafana-dashboards-provider"
  }

  application {
    offer_url = data.juju_offer.grafana_dashboards.url
  }
}

resource "juju_integration" "opentelemetry_collector_k8s_loki" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.opentelemetry_collector_k8s.name
    endpoint = "send-loki-logs"
  }

  application {
    offer_url = data.juju_offer.loki_logging.url
  }
}

resource "juju_integration" "opentelemetry_collector_k8s_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.opentelemetry_collector_k8s.name
    endpoint = "send-remote-write"
  }

  application {
    offer_url = data.juju_offer.prometheus_receive_remote_write.url
  }
}

# ---------------------------------------------------------------------------
# Metrics endpoints (prometheus_scrape): charm -> collector
# ---------------------------------------------------------------------------

resource "juju_integration" "kserve_controller_metrics_endpoint" {
  count      = var.kserve_controller_metrics_endpoint != null ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = var.kserve_controller_metrics_endpoint.name
    endpoint = var.kserve_controller_metrics_endpoint.endpoint
  }

  application {
    name     = juju_application.opentelemetry_collector_k8s.name
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "kserve_llmisvc_metrics_endpoint" {
  count      = var.kserve_llmisvc_metrics_endpoint != null ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = var.kserve_llmisvc_metrics_endpoint.name
    endpoint = var.kserve_llmisvc_metrics_endpoint.endpoint
  }

  application {
    name     = juju_application.opentelemetry_collector_k8s.name
    endpoint = "metrics-endpoint"
  }
}

# ---------------------------------------------------------------------------
# Grafana dashboards: charm -> collector
# ---------------------------------------------------------------------------

resource "juju_integration" "kserve_llmisvc_grafana_dashboard" {
  count      = var.kserve_llmisvc_grafana_dashboard != null ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = var.kserve_llmisvc_grafana_dashboard.name
    endpoint = var.kserve_llmisvc_grafana_dashboard.endpoint
  }

  application {
    name     = juju_application.opentelemetry_collector_k8s.name
    endpoint = "grafana-dashboards-consumer"
  }
}

# ---------------------------------------------------------------------------
# Logging (loki_push_api): charm -> collector
# ---------------------------------------------------------------------------

resource "juju_integration" "kserve_controller_logging" {
  count      = var.kserve_controller_logging != null ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = var.kserve_controller_logging.name
    endpoint = var.kserve_controller_logging.endpoint
  }

  application {
    name     = juju_application.opentelemetry_collector_k8s.name
    endpoint = "receive-loki-logs"
  }
}

resource "juju_integration" "kserve_llmisvc_logging" {
  count      = var.kserve_llmisvc_logging != null ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = var.kserve_llmisvc_logging.name
    endpoint = var.kserve_llmisvc_logging.endpoint
  }

  application {
    name     = juju_application.opentelemetry_collector_k8s.name
    endpoint = "receive-loki-logs"
  }
}

resource "juju_integration" "lws_controller_logging" {
  count      = var.lws_controller_logging != null ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = var.lws_controller_logging.name
    endpoint = var.lws_controller_logging.endpoint
  }

  application {
    name     = juju_application.opentelemetry_collector_k8s.name
    endpoint = "receive-loki-logs"
  }
}
