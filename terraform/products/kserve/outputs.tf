# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

output "model_uuid" {
  description = "UUID of the Juju model the KServe serving stack is deployed into"
  value       = local.model_uuid
}

output "istio" {
  description = "Outputs of the active Istio component (components, provides, requires). In knative mode this is the istio-sidecar component; in standard mode it is the istio-ambient component."
  value = local.knative ? {
    components = module.istio[0].components
    provides   = module.istio[0].provides
    requires   = module.istio[0].requires
    } : {
    components = module.istio_ambient[0].components
    provides   = module.istio_ambient[0].provides
    requires   = module.istio_ambient[0].requires
  }
}

output "kserve" {
  description = "Outputs of the KServe component (components, provides, requires). Knative apps are present only in knative mode."
  value = {
    components = module.kserve.components
    provides   = module.kserve.provides
    requires   = module.kserve.requires
  }
}
