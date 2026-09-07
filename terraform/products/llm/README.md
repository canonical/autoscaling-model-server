# LLM serving product

This product deploys the **LLM inference serving** configuration of the
autoscaling-model-serving solution. It uses the [Envoy
Gateway](../../components/envoy) as the ingress and AI Gateway control plane and
the [KServe LLM serving](../../components/kserve-llm) control plane. It does
**not** deploy Knative or Istio.

For the classic KServe serving configuration (Istio sidecar + Knative), see the
[`kserve` product](../kserve).

## Components

| Module | Source | Role |
| --- | --- | --- |
| `envoy` | `../../components/envoy` | Envoy Gateway ingress + AI Gateway control plane + certificates. |
| `kserve_llm` | `../../components/kserve-llm` | `kserve-controller` (standard mode) + `kserve-llmisvc` + `lws-controller`. |

## Product-level wiring

- `envoy-ingress-k8s:gateway-metadata` → `kserve-controller:gateway-metadata`
  (passed as the `gateway_metadata` input to the `kserve-llm` component).

`llm-integrator` is intentionally not deployed; the end user deploys it and
relates it to `kserve-llmisvc` via the component's `kserve_llmisvc_sync`
provided endpoint.

## Observability (COS)

Set `enable_observability = true` to deploy an `opentelemetry-collector-k8s`
([`observability` component](../../components/observability)) that aggregates the
KServe LLM charms' metrics, logs and dashboards and forwards them to a
cross-model COS stack. The three `*_offer` URLs are required when enabled. The
Envoy charms are not wired (they export metrics over `otlp`).

```hcl
module "llm_serving" {
  source = "github.com/canonical/autoscaling-model-serving//terraform/products/llm"

  enable_observability = true
  dashboards_offer     = "admin/cos.grafana-dashboards"
  logging_offer        = "admin/cos.loki-logging"
  metrics_offer        = "admin/cos.prometheus-receive-remote-write"
}
```

## Usage

```hcl
module "llm_serving" {
  source = "github.com/canonical/autoscaling-model-serving//terraform/products/llm"

  create_model = true
  model_name   = "kserve-llm"
  cloud        = "k8s"
}
```

To deploy into an existing model, set `create_model = false` and provide
`model_uuid`.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `create_model` | `bool` | `true` | Create the Juju model or reuse an existing one. |
| `model_name` | `string` | `"kserve-llm"` | Model name when creating a model. |
| `model_uuid` | `string` | `null` | Existing model UUID when `create_model = false`. |
| `cloud` | `string` | `null` | Kubernetes cloud to create the model on. |
| `envoy_channel` | `string` | `"latest/edge"` | Channel for the Envoy Gateway charms. |
| `self_signed_certificates_channel` | `string` | `"latest/stable"` | Channel for self-signed-certificates. |
| `kserve_channel` | `string` | `"latest/edge"` | Channel for kserve-controller and kserve-llmisvc. |
| `lws_controller_channel` | `string` | `"latest/edge"` | Channel for lws-controller. |
| `*_revision` | `number` | `null` | Optional per-charm revision pins. |
| `kserve_controller_config` | `map(string)` | `{}` | Extra kserve-controller config merged over defaults. |
| `enable_observability` | `bool` | `false` | Deploy the observability collector and wire it to COS. |
| `dashboards_offer` / `logging_offer` / `metrics_offer` | `string` | `null` | COS offer URLs (required when `enable_observability = true`). |
| `opentelemetry_collector_k8s_revision` | `number` | `null` | Optional collector revision pin. |
| `opentelemetry_collector_k8s_config` | `map(string)` | `{}` | Extra collector config. |

## Outputs

- `model_uuid` — UUID of the deployment model.
- `envoy` — `components` / `provides` / `requires` of the Envoy component.
- `kserve_llm` — `components` / `provides` / `requires` of the KServe LLM component.
- `observability` — `components` / `provides` of the observability component (`null` when disabled).
