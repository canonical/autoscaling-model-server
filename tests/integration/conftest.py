# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

import json

import jubilant
import pytest

# Maps a --scenario to the deployment model name, the Terraform root module to
# apply (relative to the repository root), and the extra `-var` arguments.
SCENARIOS = {
    "kserve-serverless": {
        "model": "kserve",
        "module_path": "terraform/products/kserve",
        "tf_vars": ["-var", "kserve_mode=serverless"],
    },
    "kserve-standard": {
        "model": "kserve",
        "module_path": "terraform/products/kserve",
        "tf_vars": ["-var", "kserve_mode=standard"],
    },
    "llm-cos": {
        "model": "kserve-llm",
        "module_path": "terraform/deployments/llm-cos",
        "tf_vars": [],
    },
}


def pytest_addoption(parser):
    """Add CLI options to pytest."""
    parser.addoption(
        "--scenario",
        choices=list(SCENARIOS),
        default="kserve-serverless",
        help="Deployment scenario to test.",
    )


@pytest.fixture(scope="module")
def scenario(request) -> str:
    """Return the selected deployment scenario."""
    return request.config.getoption("--scenario")


@pytest.fixture(scope="module")
def juju(scenario):
    """Create a jubilant.Juju handle bound to a fresh model for the scenario."""
    juju_instance = jubilant.Juju()
    juju_instance.add_model(SCENARIOS[scenario]["model"])
    yield juju_instance


@pytest.fixture(scope="module")
def model_uuid(juju, scenario) -> str:
    """Return the UUID of the pre-created deployment model."""
    model = SCENARIOS[scenario]["model"]
    # `juju show-model` takes the model as a positional, so suppress jubilant's
    # automatic `--model` injection.
    out = juju.cli("show-model", model, "--format=json", include_model=False)
    return json.loads(out)[model]["model-uuid"]


@pytest.fixture(scope="module")
def solution_module_path(scenario) -> str:
    """Return the path to the Terraform root module for the selected scenario."""
    return SCENARIOS[scenario]["module_path"]


@pytest.fixture(scope="module")
def tf_vars(scenario, model_uuid) -> list[str]:
    """Build the Terraform `-var` arguments for the selected scenario.

    The deployment model is pre-created by the `juju` fixture and referenced by
    its UUID, so every scenario deploys with `create_model=false`. kserve
    scenarios also pass `model_name` (used to configure Knative's gateway
    namespace).
    """
    common = ["-var", f"model_uuid={model_uuid}"]
    if scenario.startswith("kserve-"):
        common += [
            "-var",
            "create_model=false",
            "-var",
            f"model_name={SCENARIOS[scenario]['model']}",
        ]
    return common + SCENARIOS[scenario]["tf_vars"]
