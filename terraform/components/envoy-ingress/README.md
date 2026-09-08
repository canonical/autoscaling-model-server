# Envoy ingress component

Deploys `envoy-ingress-k8s`, which manages the user-facing Gateway API resources
(Gateway, HTTPRoute, SecurityPolicy) and publishes gateway metadata to
downstream consumers such as `kserve-controller`. It is a separate component
from the Envoy Gateway control plane ([`envoy` component](../envoy)) so the
ingress/data plane can be managed independently; the control plane reconciles it
through the Gateway API CRDs (no direct Juju relation between them).

Like the `envoy` component, this is a **local** component because the Envoy
charms ([`canonical/service-mesh`](https://github.com/canonical/service-mesh)) do
not yet ship Terraform modules; the application is declared inline.

## Inputs

| Name | Type | Description |
| --- | --- | --- |
| `model_uuid` | `string` | UUID of the Juju model to deploy into. |
| `envoy_ingress_k8s` | `object` | Configuration for `envoy-ingress-k8s`. |

## Outputs

- `components` — the deployed `envoy-ingress-k8s` `juju_application`.
- `provides` — `envoy_ingress_gateway_metadata`, `envoy_ingress_ingress`.
- `requires` — `envoy_ingress_certificates`, `envoy_ingress_forward_auth` (both optional).
