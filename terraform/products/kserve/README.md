# KServe serving product

This product deploys the classic **KServe serving** configuration. It supports
two modes via `kserve_mode`:

- **`serverless`** (default) — Istio in **sidecar** mode + Knative serving +
  the KServe control plane in `knative` mode.
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
(`istio-sidecar` + `kserve` for serverless, `istio-ambient-dex` for standard),
pinned to commit `7cf3c85bde844a060ec985c1b3aa97c57d3fa3fc` (the upstream
repository has no tags).

## Components

| Module | Mode | Source | Role |
| --- | --- | --- | --- |
| `istio` | serverless | `charmed-kubeflow-solutions//terraform/components/istio-sidecar` | Istio control plane + ingress gateway (sidecar). |
| `istio_ambient` | standard | `charmed-kubeflow-solutions//terraform/components/istio-ambient-dex` | Ambient mesh: istio-k8s + istio-ingress-k8s + istio-beacon-k8s. |
| `kserve` | both | `charmed-kubeflow-solutions//terraform/components/kserve` | KServe control plane; Knative is deployed only when `gateway_info` is set (serverless). |

The upstream `kserve` component is used for both modes — it deploys Knative only
when `gateway_info` is provided, so standard mode (which passes `gateway_metadata`
+ `service_mesh` instead) gets `kserve-controller` alone.

## Product-level wiring

- **serverless:** `istio-pilot:gateway-info` → `kserve-controller:ingress-gateway`
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
| `kserve_mode` | `string` | `"serverless"` | `serverless` (Knative) or `standard` (RawDeployment, no Knative). |
| `model_name` | `string` | `"kserve"` | Model name (also used for the Knative gateway namespace). |
| `model_uuid` | `string` | `null` | Existing model UUID when `create_model = false`. |
| `cloud` | `string` | `null` | Kubernetes cloud to create the model on. |
| `istio_default_gateway` | `string` | `"kserve-gateway"` | Istio gateway name shared with Knative. |
| `istio_channel` | `string` | `"1.28/stable"` | Channel for the sidecar Istio charms (serverless). |
| `istio_k8s_channel` | `string` | `"2/stable"` | Channel for the ambient Istio charms (standard). |
| `knative_channel` | `string` | `"1.16/stable"` | Channel for the Knative charms. |
| `kserve_channel` | `string` | `"latest/edge"` | Channel for kserve-controller. |
| `*_revision` | `number` | `null` | Optional per-charm revision pins. |
| `kserve_controller_config` | `map(string)` | `{}` | Extra kserve-controller config merged over defaults. |

## Outputs

- `model_uuid` — UUID of the deployment model.
- `istio` — `components` / `provides` / `requires` of the Istio component.
- `kserve` — `components` / `provides` / `requires` of the KServe component.
