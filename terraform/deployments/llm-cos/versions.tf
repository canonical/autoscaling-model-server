# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

terraform {
  # >= 1.9 because cos_model_uuid's validation references another input
  # variable (var.create_cos_model), which is only supported from 1.9 onward.
  required_version = ">= 1.9"

  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.1.1"
    }
  }
}
