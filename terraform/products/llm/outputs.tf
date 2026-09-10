# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

output "model_uuid" {
  description = "UUID of the Juju model the LLM serving stack is deployed into"
  value       = local.model_uuid
}

output "envoy" {
  description = "Outputs of the Envoy Gateway control-plane component (components, provides, requires)"
  value = {
    components = module.envoy.components
    provides   = module.envoy.provides
    requires   = module.envoy.requires
  }
}

output "envoy_ingress" {
  description = "Outputs of the Envoy ingress component (components, provides, requires)"
  value = {
    components = module.envoy_ingress.components
    provides   = module.envoy_ingress.provides
    requires   = module.envoy_ingress.requires
  }
}

output "kserve_llm" {
  description = "Outputs of the KServe LLM serving component (components, provides, requires)"
  value = {
    components = module.kserve_llm.components
    provides   = module.kserve_llm.provides
    requires   = module.kserve_llm.requires
  }
}

output "lws_controller" {
  description = "Outputs of the lws-controller component (components, provides, requires)"
  value = {
    components = module.lws_controller.components
    provides   = module.lws_controller.provides
    requires   = module.lws_controller.requires
  }
}

output "observability" {
  description = "Outputs of the observability component (components, provides). Null when observability is disabled."
  value = var.enable_observability ? {
    components = module.observability[0].components
    provides   = module.observability[0].provides
  } : null
}
