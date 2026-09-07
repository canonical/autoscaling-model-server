# Autoscaling Model Serving Solution

The autoscaling model serving solution deploys KServe on any Kubernetes cluster.
It ships two product configurations:

* **KServe serving** — the KServe control plane with a `kserve_mode` switch:
  `serverless` (Istio sidecar + Knative) or `standard` (Istio ambient,
  RawDeployment). No LLM charms.
* **LLM serving** — Envoy Gateway + KServe LLM serving
  (`kserve-controller` in standard mode, `kserve-llmisvc`, `lws-controller`),
  with optional COS observability. No Knative/Istio. The end user then deploys
  `llm-integrator` (or applies `LLMInferenceService` resources) to serve models.

## Install

This repository contains a Terraform solution for the `autoscaling-model-serving`, for more information on usage, please refer to the [solution README.md](https://github.com/canonical/autoscaling-model-serving/tree/track/0.1/terraform).
