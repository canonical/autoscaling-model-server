# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# COS Lite deployed in its own model. Mirrors the kubeflow-cos test scenario:
# the LLM serving stack is wired to COS via the cross-model offers below.
resource "juju_model" "cos" {
  count = var.create_cos_model ? 1 : 0
  name  = var.cos_model_name
}

module "cos" {
  source = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=04ab6c618dbbec62292a052a61cdb402d80e5974"

  model_uuid   = var.create_cos_model ? juju_model.cos[0].uuid : var.cos_model_uuid
  channel      = var.cos_channel
  internal_tls = false
}

# LLM serving stack with observability enabled and wired to the COS offers.
module "llm" {
  source = "../../products/llm"

  create_model = false
  model_uuid   = var.model_uuid

  enable_observability = true
  dashboards_offer     = module.cos.offers.grafana_dashboards.url
  logging_offer        = module.cos.offers.loki_logging.url
  metrics_offer        = module.cos.offers.prometheus_receive_remote_write.url
}
