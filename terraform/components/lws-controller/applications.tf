# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# LeaderWorkerSet controller (manages multi-node inference worker groups).
resource "juju_application" "lws_controller" {
  charm {
    name     = "lws-controller"
    channel  = var.lws_controller.channel
    revision = var.lws_controller.revision
  }

  model_uuid  = var.model_uuid
  name        = var.lws_controller.app_name
  units       = var.lws_controller.units
  trust       = var.lws_controller.trust
  constraints = var.lws_controller.constraints
  config      = var.lws_controller.config
  resources   = var.lws_controller.resources
}
