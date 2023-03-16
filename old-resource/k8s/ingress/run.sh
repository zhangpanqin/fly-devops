#!/bin/bash

# eo 用于命令执行失败，停止执行脚本
# x 用于显示命令和对应结果
# u 忽略没有定义的变量can
set -euxo pipefail

# 如果存在先删除 kind delete clusters nginx-ingress-cluster
kind create cluster --config ./kind-create-cluster.yml

kubectl cluster-info --context kind-nginx-ingress-cluster

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=200s

sleep 10s

kubectl apply -f ./kubectl-create.yml


