# KServe LLM serving component

This component deploys the KServe control plane for **LLM inference serving**:
`kserve-controller` (in `standard` deployment mode) and the `kserve-llmisvc`
controller that reconciles `LLMInferenceService` resources.

The `lws-controller` (LeaderWorkerSet) lives in its own
[`lws-controller` component](../lws-controller); the consuming product wires it
to `kserve-llmisvc` (via the `kserve_llmisvc_lws_controller` endpoint exposed in
`requires`).

The applications are declared inline (rather than sourcing the per-charm
Terraform modules) so that the whole component is `model_uuid`-based and
consistent with the rest of the solution.

> **Note:** `llm-integrator` is intentionally excluded. It is deployed by the
> end user on top of this stack and related to `kserve-llmisvc` via the
> `kserve_llmisvc_sync` provided endpoint.

## Applications

| Application | Charm | Role |
| --- | --- | --- |
| `kserve-controller` | `kserve-controller` | KServe control plane (standard mode). |
| `kserve-llmisvc` | `kserve-llmisvc` | Reconciles `LLMInferenceService` resources. |

## Intra-component integrations

- `kserve-controller:kserve-controller` ↔ `kserve-llmisvc:kserve-controller`

## Inputs

| Name | Type | Description |
| --- | --- | --- |
| `model_uuid` | `string` | UUID of the Juju model to deploy into. |
| `kserve_controller` | `object` | Configuration for `kserve-controller`. |
| `kserve_llmisvc` | `object` | Configuration for `kserve-llmisvc`. |
| `gateway_metadata` | `object` | Gateway metadata endpoint (`{kind, name, endpoint, url}`) consumed by `kserve-controller`. `null` to skip. |

## Outputs

- `components` — map of the deployed `juju_application` resources.
- `provides` — outbound endpoints (`kserve_llmisvc_sync`, metrics and dashboard endpoints).
- `requires` — inbound endpoints (`gateway-metadata`, `logging`).
