# Autoscaling model serving — Terraform

Terraform modules for deploying the autoscaling model serving solution with the
[Terraform Juju provider](https://github.com/juju/terraform-provider-juju/).

The solution follows the Charm Terraform standards (CC008): reusable **charm**
and **component** modules composed into **product** modules. There are two
product configurations:

| Product | Path | What it deploys |
| --- | --- | --- |
| **KServe serving** | [`products/kserve`](products/kserve) | KServe control plane with a `kserve_mode` switch: `serverless` (Istio sidecar + Knative) or `standard` (Istio ambient, RawDeployment). No LLM charms. |
| **LLM serving** | [`products/llm`](products/llm) | Envoy Gateway + KServe LLM serving (`kserve-controller` standard, `kserve-llmisvc`, `lws-controller`), with optional COS observability. |

## Layout

```
terraform/
├── components/
│   ├── envoy/         # Envoy Gateway stack (local, inline; service-mesh charms)
│   ├── kserve-llm/    # kserve-controller (standard) + kserve-llmisvc + lws-controller
│   └── observability/ # opentelemetry-collector-k8s + COS offers
├── products/
│   ├── kserve/        # serverless (sidecar+knative) OR standard (ambient); reuses kubeflow components
│   └── llm/           # composes the envoy + kserve-llm (+ observability) components
└── deployments/
    └── llm-cos/       # deployment root: cos-lite + the llm product wired to COS
```

- The **`kserve`** product reuses the `istio-sidecar`, `istio-ambient-dex` and
  `kserve` components from [Charmed Kubeflow
  Solutions](https://github.com/canonical/charmed-kubeflow-solutions), pinned to
  a commit (the upstream repository has no tags).
- The **`envoy`** component is local because the
  [`service-mesh`](https://github.com/canonical/service-mesh) Envoy charms do not
  yet ship Terraform modules; its applications are declared inline. It is
  intended to be handed over to the service mesh team once upstream modules
  exist.

All modules use the Juju provider `>= 1.1.1` and address models by
`model_uuid`.

## Usage

Pick a product and run Terraform from its directory:

```
cd products/llm      # or products/kserve
terraform init
terraform apply -var model_name=kserve-llm -var cloud=k8s
```

To deploy into an existing model, set `-var create_model=false` and provide
`-var model_uuid=<uuid>`.

See each product's `README.md` for its full input/output reference.

## LLM serving: deploying models

The `llm` product does not deploy `llm-integrator`. After apply, the end user
relates it to `kserve-llmisvc` to serve a model:

```
juju deploy llm-integrator --channel latest/edge --trust \
  --config model-uri="hf://EleutherAI/pythia-70m" \
  --config model-name="EleutherAI/pythia-70m"
juju integrate llm-integrator:kserve-llmisvc kserve-llmisvc:kserve-llmisvc
```

## Linting

```
tox -e tflint
```
