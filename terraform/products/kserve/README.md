# KServe serving product

This product deploys the classic **KServe serving** configuration in either of
the two modes KServe supports, selected via `kserve_mode`:

- **`knative`** (default) — Istio in **sidecar** mode + Knative serving +
  the KServe control plane in `knative` deployment mode.
- **`standard`** — Istio in **ambient** mode (istio-k8s + istio-ingress-k8s +
  istio-beacon-k8s) + `kserve-controller` in RawDeployment mode (no Knative).
  InferenceServices are exposed externally through the Gateway API
  (`gateway-metadata` + `service-mesh`).

Either way it does **not** deploy the LLM serving charms (`kserve-llmisvc`,
`lws-controller`) or the Envoy Gateway stack.

For the LLM inference serving configuration (Envoy + KServe LLM), see the
[`llm` product](../llm).

It reuses [Charmed Kubeflow
Solutions](https://github.com/canonical/charmed-kubeflow-solutions) components
(`istio-sidecar` + `kserve` for knative, `istio-ambient-dex` for standard),
pinned to a commit because the upstream repository has no tags (see `main.tf`
for the exact ref).

## Components

| Module | Mode | Source | Role |
| --- | --- | --- | --- |
| `istio` | knative | `charmed-kubeflow-solutions//terraform/components/istio-sidecar` | Istio control plane + ingress gateway (sidecar). |
| `istio_ambient` | standard | `charmed-kubeflow-solutions//terraform/components/istio-ambient-dex` | Ambient mesh: istio-k8s + istio-ingress-k8s + istio-beacon-k8s. |
| `kserve` | both | `charmed-kubeflow-solutions//terraform/components/kserve` | KServe control plane; Knative is deployed only when `gateway_info` is set (knative). |

The upstream `kserve` component is used for both modes — it deploys Knative only
when `gateway_info` is provided, so standard mode (which passes `gateway_metadata`
+ `service_mesh` instead) gets `kserve-controller` alone.

## Product-level wiring

- **knative:** `istio-pilot:gateway-info` → `kserve-controller:ingress-gateway`
  (the `kserve` component also wires `knative-serving:local-gateway` →
  `kserve-controller:local-gateway`).
- **standard:** `istio-ingress-k8s:gateway-metadata` →
  `kserve-controller:gateway-metadata` and `istio-beacon-k8s:service-mesh` →
  `kserve-controller:service-mesh` (Gateway API ingress; no Knative).

## Usage

```hcl
module "kserve_serving" {
  source = "github.com/canonical/autoscaling-model-serving//terraform/products/kserve"

  create_model = true
  model_name   = "kserve"
  cloud        = "k8s"
}
```

To deploy into an existing model, set `create_model = false` and provide
`model_uuid` (still provide `model_name`; it configures Knative's ingress
gateway namespace).

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `create_model` | `bool` | `true` | Create the Juju model or reuse an existing one. |
| `kserve_mode` | `string` | `"knative"` | `knative` (Knative) or `standard` (RawDeployment, no Knative). |
| `model_name` | `string` | `"kserve"` | Model name (also used for the Knative gateway namespace). |
| `model_uuid` | `string` | `null` | Existing model UUID when `create_model = false`. |
| `cloud` | `string` | `null` | Kubernetes cloud to create the model on. |
| `istio_default_gateway` | `string` | `"kserve-gateway"` | Istio gateway name shared with Knative. |
| `*_channel` | `string` | see defaults | Per-charm channels: `istio_channel` `1.28/stable`, `istio_k8s_channel` `2/stable`, `knative_channel` `1.16/stable`, `kserve_channel` `latest/edge`. |
| `*_revision` | `number` | `null` | Optional per-charm revision pins. |
| `kserve_controller_config` | `map(string)` | `{}` | Extra kserve-controller config merged over defaults. |

## Outputs

- `model_uuid` — UUID of the deployment model.
- `istio` — `components` / `provides` / `requires` of the Istio component.
- `kserve` — `components` / `provides` / `requires` of the KServe component.
