# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# Extension Server: envoy-controller delegates AI-specific xDS fine-tuning to
# envoy-ai-controller. This relation is the AI Gateway on/off switch.
resource "juju_integration" "envoy_controller_extension_server" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.envoy_controller_k8s.name
    endpoint = "envoy-extension-server"
  }

  application {
    name     = juju_application.envoy_ai_controller_k8s.name
    endpoint = "envoy-extension-server"
  }
}
