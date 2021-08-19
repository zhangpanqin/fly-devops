#!/bin/bash

set -euxo pipefail

# 如果存在先删除 kind delete clusters export-node-cluster
kind create cluster --config ./export-node.yaml

kubectl cluster-info --context kind-export-node-cluster


kubectl apply -f ./kubectl-create.yml