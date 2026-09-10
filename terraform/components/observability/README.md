# Observability component

Deploys an `opentelemetry-collector-k8s` that aggregates telemetry from the
KServe LLM serving charms (`kserve-controller`, `kserve-llmisvc`,
`lws-controller`) and forwards it to a (typically cross-model) COS stack. This
mirrors the `observability` component of [Charmed Kubeflow
Solutions](https://github.com/canonical/charmed-kubeflow-solutions).

The Envoy Gateway charms are intentionally **not** wired here; they export
workload metrics over `otlp` rather than `prometheus_scrape`.

## Collector → COS (always on)

| Collector endpoint | COS offer |
| --- | --- |
| `grafana-dashboards-provider` | `dashboards_offer` (`grafana_dashboard`) |
| `send-loki-logs` | `logging_offer` (`loki_push_api`) |
| `send-remote-write` | `metrics_offer` (`prometheus_remote_write`) |

## Charm → Collector (gated on each input being set)

| Input var | Source charm endpoint | Collector endpoint |
| --- | --- | --- |
| `kserve_controller_metrics_endpoint` | `kserve-controller:metrics-endpoint` | `metrics-endpoint` |
| `kserve_llmisvc_metrics_endpoint` | `kserve-llmisvc:metrics-endpoint` | `metrics-endpoint` |
| `kserve_llmisvc_grafana_dashboard` | `kserve-llmisvc:grafana-dashboard` | `grafana-dashboards-consumer` |
| `kserve_controller_logging` | `kserve-controller:logging` | `receive-loki-logs` |
| `kserve_llmisvc_logging` | `kserve-llmisvc:logging` | `receive-loki-logs` |
| `lws_controller_logging` | `lws-controller:logging` | `receive-loki-logs` |

## Inputs

| Name | Type | Description |
| --- | --- | --- |
| `model_uuid` | `string` | UUID of the Juju model to deploy into. |
| `opentelemetry_collector_k8s` | `object` | Configuration for `opentelemetry-collector-k8s`. |
| `dashboards_offer` | `string` | `grafana_dashboard` offer URL from the COS stack. |
| `logging_offer` | `string` | `loki_push_api` offer URL from the COS stack. |
| `metrics_offer` | `string` | `prometheus_remote_write` offer URL from the COS stack. |
| `*_metrics_endpoint` / `*_grafana_dashboard` / `*_logging` | `object({name, endpoint})` | Observed-charm endpoints (`null` to skip). |

## Outputs

- `components` — the deployed collector `juju_application`.
- `provides` — the collector's outbound COS endpoints.
