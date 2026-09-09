# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

locals {
  # UUID of the model everything is deployed into: either the freshly created
  # model or an existing one supplied by the caller.
  model_uuid = var.create_model ? juju_model.kserve[0].uuid : var.model_uuid

  knative  = var.kserve_mode == "knative"
  standard = var.kserve_mode == "standard"
}
