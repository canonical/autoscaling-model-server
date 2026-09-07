# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

import json
import logging
import pathlib
import subprocess

import jubilant
import pytest

logger = logging.getLogger(__name__)

# COS model + expected cross-model offers consumed by the llm-cos scenario.
COS_MODEL = "cos"
COS_SAAS = [
    "grafana-dashboards",
    "loki-logging",
    "prometheus-receive-remote-write",
]


@pytest.mark.dependency()
def test_apply_terraform_solution(solution_module_path, tf_vars):
    """Initialize and apply the selected Terraform root module."""
    # Each test owns its (freshly created) model; drop any local state left over
    # from a previous run so the apply always starts clean.
    module = pathlib.Path(solution_module_path)
    for stale in ("terraform.tfstate", "terraform.tfstate.backup"):
        (module / stale).unlink(missing_ok=True)

    subprocess.run(["terraform", "init"], check=True, cwd=solution_module_path)
    subprocess.run(
        ["terraform", "apply", "-auto-approve"] + tf_vars,
        check=True,
        cwd=solution_module_path,
    )


@pytest.mark.dependency(depends=["test_apply_terraform_solution"])
def test_charms_active(juju: jubilant.Juju, scenario):
    """Wait for all deployed applications to become active and idle."""
    juju.wait(jubilant.all_active, timeout=3600, delay=10)

    # The llm-cos scenario also stands up COS in its own model.
    if scenario == "llm-cos":
        cos = jubilant.Juju(model=COS_MODEL)
        cos.wait(jubilant.all_active, timeout=3600, delay=10)


@pytest.mark.dependency(depends=["test_charms_active"])
def test_cos_relations_active(juju: jubilant.Juju, scenario):
    """Assert the cross-model COS relations are established (llm-cos only)."""
    if scenario != "llm-cos":
        pytest.skip("COS relations are only asserted for the llm-cos scenario")

    status = json.loads(juju.cli("status", "--format=json"))
    saas = status.get("application-endpoints", {})
    for offer in COS_SAAS:
        assert offer in saas, f"expected consumed offer {offer!r} not found in {list(saas)}"
        current = saas[offer].get("application-status", {}).get("current")
        logger.info("SAAS %s status: %s", offer, current)
        assert current == "active", f"offer {offer} is {current!r}, expected 'active'"
