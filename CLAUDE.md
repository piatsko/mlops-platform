# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Infrastructure toolchain

**All infrastructure is managed exclusively with [OpenTofu](https://opentofu.org/).**
Use `tofu` for every plan/apply/destroy operation — never `terraform`.

## Kubernetes cluster

The cluster runs locally inside Docker using **[kind](https://kind.sigs.k8s.io/)** (Kubernetes IN Docker).

| Detail | Value |
|---|---|
| Provider | `tehcyx/kind` ~> 0.7.0 |
| Default node image | `kindest/node:v1.31.0` |
| Default topology | 1 control-plane + 2 workers |
| Host port mapping | `localhost:8080` → node port `30080` (Coder) |

The kubeconfig is written to `{cluster_name}-config` (e.g. `mtb-mirror-config`) in the repo root by the kind provider after cluster creation.

## Coder deployment

Coder is deployed into the `coder` namespace via its official Helm chart.

| Detail | Value |
|---|---|
| Chart | `https://helm.coder.com/v2` coder `2.32.1` (stable) |
| Database | Bitnami PostgreSQL (OCI chart, in-cluster, no persistence) |
| Access URL | `http://localhost:8080` |
| Service | ClusterIP + separate NodePort service on `30080` |
| Workspaces namespace | `coder-workspaces` (separate namespace, RBAC wired) |

The `coder` module also creates `coder-workspaces` namespace with a `Role`/`RoleBinding` granting Coder's service account pod/service/PVC management rights there.

## Workspace templates

`coderd/templates/` contains Coder workspace templates (use `coder/coder` provider, not `coder/coderd`):

- **kubernetes-workspace** — Kubernetes pod per workspace; selectable base image (default `codercom/enterprise-base:ubuntu`); `code-server` (VS Code in browser) installed on startup; `localhost` replaced with `host.docker.internal` in the agent init script (required for kind)
- **data-science** — JupyterLab on `jupyter/scipy-notebook`

The `coderd` root (`coder/coderd` provider) uploads these templates to Coder — run `tofu apply` inside `coderd/` once you have an API token.

## Module structure

```
.
├── main.tf              # root — calls kind-cluster and coder modules
├── variables.tf
├── outputs.tf
├── versions.tf          # required_providers (kind, helm, kubernetes, random)
├── providers.tf         # helm + kubernetes providers (read kubeconfig)
├── kind-cluster/        # kind_cluster resource
├── coder/               # namespace + postgresql + secret + coder helm + nodeport svc + RBAC
├── coderd/              # separate Tofu root — coderd_template resources + workspace template HCL
│   └── templates/
│       ├── data-science/
│       └── kubernetes-workspace/
└── kserve/              # separate Tofu root — KServe on Knative mode (on-prem cluster)
    └── modules/
        ├── cert-manager/
        ├── istio/
        ├── knative/
        ├── kserve/
        └── llmisvc/     # optional — Gateway API + LWS + Envoy Gateway + LLMInferenceService
```

## Deployment workflow

The `helm` and `kubernetes` providers require the kubeconfig file to exist before they can initialize, so a fresh environment needs three steps:

```bash
tofu init
tofu apply -target=module.cluster   # step 1: create cluster, write kubeconfig
tofu apply                          # step 2: deploy Coder
# Complete first-time Coder setup at http://localhost:8080, then create an API token
# at http://localhost:8080/settings/tokens and set it in coderd/terraform.tfvars
cd coderd && tofu init && tofu apply # step 3: upload workspace templates
```

**Subsequent changes** (cluster already exists):

```bash
tofu apply          # from repo root — cluster + coder
cd coderd && tofu apply  # workspace templates
```

## Common commands

```bash
# Tear everything down
tofu destroy

# Check cluster nodes
kubectl --kubeconfig mtb-mirror-config get nodes

# Check Coder pods
kubectl --kubeconfig mtb-mirror-config get pods -n coder

# Check workspace pods
kubectl --kubeconfig mtb-mirror-config get pods -n coder-workspaces
```

## Prerequisites

- Docker running locally
- `kind` CLI — `brew install kind`
- OpenTofu — `brew install opentofu`

## Key variables

| Variable | Default | Description |
|---|---|---|
| `cluster_name` | `mtb-mirror` | kind cluster name (also determines kubeconfig filename) |
| `node_image` | `kindest/node:v1.31.0` | Kubernetes version |
| `worker_count` | `2` | Number of worker nodes |
| `coder_api_token` | `""` | Coder API token; when empty the `coderd_template` resource is skipped |
| `extra_port_mappings` | `[]` | Additional host→node port mappings |

Override variables in `terraform.tfvars` or with `-var` flags — never hardcode values.
