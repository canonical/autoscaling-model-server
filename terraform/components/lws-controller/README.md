# LWS controller component

Deploys the `lws-controller` (LeaderWorkerSet) charm, which manages multi-node
inference worker groups. It is a standalone component so it can be reused
independently of the KServe LLM serving stack.

## Inputs

| Name | Type | Description |
| --- | --- | --- |
| `model_uuid` | `string` | UUID of the Juju model to deploy into. |
| `lws_controller` | `object` | Configuration for `lws-controller`. |

## Outputs

- `components` — the deployed `lws-controller` `juju_application`.
- `provides` — `lws_controller_sync` (the `lws-controller` endpoint consumed by `kserve-llmisvc`).
- `requires` — `lws_controller_logging` (Loki logging for COS).
