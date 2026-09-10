# Autoscaling model serving — Terraform

Terraform modules for deploying the autoscaling model serving solution on top of
the [Terraform Juju provider](https://github.com/juju/terraform-provider-juju/).

The modules follow CC008: small **charm** and **component** modules composed into
**product** modules. Two products live here:

| Product | Path | What it deploys |
| --- | --- | --- |
| **KServe serving** | [`products/kserve`](products/kserve) | The KServe control plane. Pick `knative` (Istio sidecar + Knative) or `standard` (Istio ambient, RawDeployment) with `kserve_mode`. No LLM charms. |
| **LLM serving** | [`products/llm`](products/llm) | Envoy Gateway plus the KServe LLM stack (`kserve-controller`, `kserve-llmisvc`, `lws-controller`), optionally wired to COS. |

## Layout

```
terraform/
├── components/
│   ├── envoy/          # Envoy Gateway control plane (envoy-controller + ai-controller)
│   ├── envoy-ingress/  # Envoy Gateway ingress (envoy-ingress-k8s)
│   ├── kserve-llm/     # kserve-controller (standard) + kserve-llmisvc
│   ├── lws-controller/ # LeaderWorkerSet controller (multi-node inference)
│   └── observability/  # opentelemetry-collector-k8s + COS offers
├── products/
│   ├── kserve/        # knative (sidecar) OR standard (ambient); reuses kubeflow components
│   └── llm/           # envoy + envoy-ingress + kserve-llm + lws-controller (+ observability)
└── deployments/
    └── llm-cos/       # cos-lite + the llm product wired to COS
```

The `kserve` product doesn't reinvent Istio and KServe — it reuses the
`istio-sidecar`, `istio-ambient-dex` and `kserve` components from [Charmed
Kubeflow Solutions](https://github.com/canonical/charmed-kubeflow-solutions),
pinned to a commit since that repository has no tags yet.

The `envoy` component is kept local (its applications are declared inline)
because the [service mesh](https://github.com/canonical/service-mesh) Envoy
charms don't ship Terraform modules yet. Once they do, we plan to hand it over to
the service mesh team.

Everything uses the Juju provider `>= 1.1.1` and refers to models by
`model_uuid`.

## Usage

Change into a product directory and run Terraform from there:

```
cd products/llm      # or products/kserve
terraform init
terraform apply -var model_name=kserve-llm -var cloud=k8s
```

To target an existing model instead, pass `-var create_model=false` and
`-var model_uuid=<uuid>`. Each product's `README.md` lists its full inputs and
outputs.

## LLM serving: deploying models

The `llm` product deliberately stops at the serving stack — it doesn't deploy
`llm-integrator`. Once the product is up, relate `llm-integrator` to
`kserve-llmisvc` to actually serve a model:

```
juju deploy llm-integrator --channel latest/edge --trust \
  --config model-uri="hf://EleutherAI/pythia-70m" \
  --config model-name="EleutherAI/pythia-70m"
juju integrate llm-integrator:kserve-llmisvc kserve-llmisvc:kserve-llmisvc
```

## Linting & validation

```
tox -e lint            # terraform fmt -check + tflint (recursive)
tox -e validate-kserve # terraform init + validate for the kserve product
tox -e validate-llm    # ... the llm product
tox -e validate-llm-cos
tox -e fmt             # apply formatting + tflint --fix
```
