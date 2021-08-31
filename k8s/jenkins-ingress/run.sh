#!/bin/bash

set -euxo pipefail

NAME_SPACE="fly-devops"
JENKINS_SERVICE_NAME="jenkins-service"
JENKINS_USERNAME="jenkins"
JENKINS_PASSWORD="jenkins"

# 如果存在先删除 kind delete clusters kind-cluster-with-jenkins
kind create cluster --config ./kind-create-cluster.yml
#
kubectl cluster-info --context kind-cluster-with-jenkins

sleep 10s
#
kubectl create namespace ${NAME_SPACE}
#
kubectl config set-context --current --namespace=${NAME_SPACE}

# 安装 jenkins
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade ${JENKINS_SERVICE_NAME} bitnami/jenkins --install \
  --set jenkinsPassword=${JENKINS_PASSWORD} \
  --set jenkinsUser=${JENKINS_USERNAME} \
  --set ingress.enabled=false \
  --set service.type=NodePort \
  --set service.nodePorts.http=30000 \
  --namespace ${NAME_SPACE} --wait --timeout 10m0s