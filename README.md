# Autoscaling Model Serving Solution

The autoscaling model serving solution deploys KServe on any Kubernetes cluster.
It ships two product configurations:

* **KServe serving** — the KServe control plane, in either of the two modes
  KServe supports (`kserve_mode`): `knative` (Knative behind an Istio sidecar
  gateway) or `standard` (RawDeployment behind an ambient Istio gateway, no
  Knative). No LLM charms.
* **LLM serving** — the Envoy Gateway plus the KServe LLM stack
  (`kserve-controller` in standard mode, `kserve-llmisvc`, `lws-controller`),
  with COS observability available on request. You bring the models: deploy
  `llm-integrator` or apply `LLMInferenceService` resources on top.

## Install

This repository contains a Terraform solution for the `autoscaling-model-serving`, for more information on usage, please refer to the [solution README.md](https://github.com/canonical/autoscaling-model-serving/tree/track/0.1/terraform).
