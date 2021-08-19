#!/bin/bash

set -euxo pipefail

kind create cluster --config ./kind-create-cluster.yml

kubectl cluster-info --context kind-export-node-cluster-order-manage

kubectl create namespace fly-devops

kubectl config set-context --current --namespace=fly-devops

kubectl create secret docker-registry regcred \
  --docker-server=626246113265.dkr.ecr.us-east-2.amazonaws.com/order-manage-service \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=fly-devops

kubectl apply -f ./kubectl-create.yml