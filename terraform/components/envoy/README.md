# Envoy Gateway component

This component deploys the [Envoy Gateway](https://gateway.envoyproxy.io/) stack
used as the ingress and AI Gateway control plane for LLM inference serving. It is
a **local component** because the Envoy charms
([`canonical/service-mesh`](https://github.com/canonical/service-mesh)) do not
yet ship their own Terraform modules; the applications are therefore declared
inline. This component is intended to be handed over to the service mesh team
once upstream Terraform modules exist.

## Applications

| Application | Charm | Role |
| --- | --- | --- |
| `envoy-controller-k8s` | `envoy-controller-k8s` | Envoy Gateway control plane (Gateway API / Gateway Inference Extension CRDs). |
| `envoy-ai-controller-k8s` | `envoy-ai-controller-k8s` | Envoy AI Gateway control plane; serves the Extension Server protocol. |
| `envoy-ingress-k8s` | `envoy-ingress-k8s` | User-facing Gateway API resources; publishes gateway metadata. |

## Intra-component integrations

- `envoy-controller-k8s:envoy-extension-server` ↔ `envoy-ai-controller-k8s:envoy-extension-server`

TLS certificates for the ExtProc admission webhook (mandatory) are **not** part
of this component — the consuming product supplies `certificates` and wires it to
the `envoy_ai_controller_certificates` endpoint exposed in `requires` (matching
how kubeflow handles self-signed-certificates at the product level).

## Inputs

| Name | Type | Description |
| --- | --- | --- |
| `model_uuid` | `string` | UUID of the Juju model to deploy into. |
| `envoy_controller_k8s` | `object` | Configuration for `envoy-controller-k8s`. |
| `envoy_ai_controller_k8s` | `object` | Configuration for `envoy-ai-controller-k8s`. |
| `envoy_ingress_k8s` | `object` | Configuration for `envoy-ingress-k8s`. |

## Outputs

- `components` — map of the deployed `juju_application` resources.
- `provides` — outbound endpoints (e.g. `envoy_ingress_gateway_metadata`, metrics and dashboard endpoints).
- `requires` — inbound endpoints (`otlp` for both controllers, `certificates` for the AI controller, `forward-auth` for the ingress).
