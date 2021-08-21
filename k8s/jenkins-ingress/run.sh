#!/bin/bash

set -euxo pipefail

NAME_SPACE="fly-devops"
JENKINS_SERVICE_NAME="jenkins-service"
JENKINS_USERNAME="jenkins"
JENKINS_PASSWORD="jenkins"

# 如果存在先删除 kind delete clusters kind-cluster-with-jenkins
#kind create cluster --config ./kind-create-cluster.yml
#
#kubectl cluster-info --context kind-cluster-with-jenkins
#
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
#
#kubectl wait --namespace ingress-nginx \
#  --for=condition=ready pod \
#  --selector=app.kubernetes.io/component=controller \
#  --timeout=200s
#
#sleep 10s
#
#kubectl create namespace fly-devops
#
#kubectl config set-context --current --namespace=${NAME_SPACE}

# 安装 jenkins
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade ${JENKINS_SERVICE_NAME} bitnami/jenkins --install \
  --set jenkinsPassword=${JENKINS_PASSWORD} \
  --set jenkinsUser=${JENKINS_USERNAME} \
  --set ingress.enabled=true \
  --namespace ${NAME_SPACE} --wait

#kubectl create secret docker-registry regcred \
#  --docker-server=626246113265.dkr.ecr.us-east-2.amazonaws.com/order-manage-service \
#  --docker-username=AWS \
#  --docker-password=$(aws ecr get-login-password) \
#  --namespace=${NAME_SPACE}
#
#kubectl apply -f ./kubectl-create.yml
