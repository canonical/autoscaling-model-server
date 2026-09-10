# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

output "components" {
  description = "Map of the deployed applications"
  value = {
    lws_controller = juju_application.lws_controller
  }
}

output "provides" {
  description = "Map of endpoints provided by this component to other components (outbound relations)"
  value = {
    # LeaderWorkerSet configuration consumed by kserve-llmisvc.
    lws_controller_sync = {
      name     = juju_application.lws_controller.name
      endpoint = "lws-controller"
    }
  }
}

output "requires" {
  description = "Map of endpoints required by this component from other components (inbound relations)"
  value = {
    lws_controller_logging = {
      name     = juju_application.lws_controller.name
      endpoint = "logging"
    }
  }
}
