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

## Workspace template

`templates/kubernetes-workspace/` is a Coder workspace template (uses `coder/coder` provider, not `coder/coderd`). It provisions a Kubernetes pod per workspace with:
- Selectable base image (default `codercom/enterprise-base:ubuntu`)
- `code-server` (VS Code in browser) installed on startup
- `localhost` replaced with `host.docker.internal` in the agent init script (required for kind)

The root `coderd_template` resource (`coder/coderd` provider) uploads this template to Coder — it only runs when `coder_api_token` is set.

## Module structure

```
.
├── main.tf              # root — calls kind-cluster and coder modules; coderd_template resource
├── variables.tf
├── outputs.tf
├── versions.tf          # required_providers (kind, helm, kubernetes, random, coderd)
├── providers.tf         # helm + kubernetes providers (read kubeconfig); coderd provider
└── modules/
    ├── kind-cluster/    # kind_cluster resource
    └── coder/           # namespace + postgresql + secret + coder helm + nodeport svc + RBAC
└── templates/
    └── kubernetes-workspace/   # Coder workspace template (coder/coder provider)
```

## Deployment workflow

The `helm` and `kubernetes` providers require the kubeconfig file to exist before they can initialize, so a fresh environment needs three steps:

```bash
tofu init
tofu apply -target=module.cluster   # step 1: create cluster, write kubeconfig
tofu apply                          # step 2: deploy Coder (no template yet)
# Complete first-time Coder setup at http://localhost:8080, then create an API token
# at http://localhost:8080/settings/tokens and set coder_api_token in terraform.tfvars
tofu apply                          # step 3: upload workspace template
```

**Subsequent changes** (cluster already exists):

```bash
tofu apply
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
