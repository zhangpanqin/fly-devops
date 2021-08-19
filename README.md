## jenkins

### 本地安装 jenkins

```shell
./gradlew composeUp
```

`fly-devops/gradle/docker-compose/jenkins/Dockerfile`

以 jenkins:lts-jdk11为基础镜像 diy，镜像基础上中添加了 aws cli,ecr , docker,docker-compose,而且初始化了一些学习 jenkins 的必要插件

#### 查看 jenkins 登录密码

```shell
# 查看 jenkins 登录密码
docker exec jenkins-local cat /var/jenkins_home/secrets/initialAdminPassword
```

#### 访问 jenkins

```txt
http://localhost:30901
```

### Jenkins 插件

- `CloudBees AWS Credentials` 保存 iam 秘钥
- `Pipeline: AWS Steps` 使用 iam 秘钥，执行 aws 命令

```groovy
// 好东西啊
withAWS(credentials: 'aws-iam-fly-devops', region: 'us-east-2') {
    sh 'aws iam get-user'
}
```

[查看插件提供的 api 还有 jenkins 自带的基础 api](https://www.jenkins.io/doc/pipeline/steps/)

### Shared Libraries

[自定义 Shared Libraries 代码参考](https://github.com/zhangpanqin/fly-devops-lib)

## AWS

### ECR

因为 ECR 免费空间为 500m，所以每次推送镜像的时候，我们都要删除上一个镜像，不然多出来的空间会占用费用

```shell
# iam 权限需要先配置
aws ecr batch-delete-image \
      --repository-name order-manage-service \
      --image-ids imageTag=latest
```

### EC2

```shell
# ec2 已经安装了 aws cli，配置 iam
aws configure

# 安装 kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# 安装 kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind

# 安装 docker
sudo yum update -y
sudo yum install docker

# 配置 docker 可以拿到认证,docker pull 有权限下载镜像
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 626246113265.dkr.ecr.us-east-2.amazonaws.com

# docker 就可以拿到镜像了
docker pull 626246113265.dkr.ecr.us-east-2.amazonaws.com/fly-devops:1.0.0

# 开机自动启动
sudo systemctl enable docker
sudo systemctl start docker

# 将用户 ec2-user 添加到 docker 用户组
sudo usermod -a -G docker ec2-user
```

aws 提供给新建用户的 EC2 的免费内存太小，我们开启 swap 交换分区

[开启 swap](https://aws.amazon.com/cn/premiumsupport/knowledge-center/ec2-memory-partition-hard-drive/)

#### 搭建 k8s 集群

注意 ec2 的内存和 cpu 要足够大，不然搭建不起来。而且 k8s 不支持 swap。我们又想支持外网访问内部 pod ，只能使用 NodePort 了。

#### 在 k8s 中使用私有镜像

`fly-devops/k8s/jenkins` 是搭建配合 jenkins 玩的 k8s 集群。

在 ec2 上安装了 kind,kubectl,docker，然后配置 iam，执行 ./run.sh 就可以自动构建k8s 集群。

```shell
#!/bin/bash

set -euxo pipefail

# 创建一个 node 的 k8s 集群，并且将宿主机的 80 端口，映射到 node 中的 30000 端口
kind create cluster --config ./kind-create-cluster.yml

kubectl cluster-info --context kind-export-node-cluster-order-manage

kubectl create namespace fly-devops

# 配置当前 context 的默认 namespace
kubectl config set-context --current --namespace=fly-devops

# 创建一个 secret，用于挂载到 pod 上，创建 pod 的时候可以 ecr pull image
kubectl create secret docker-registry regcred \
  --docker-server=626246113265.dkr.ecr.us-east-2.amazonaws.com/order-manage-service \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=fly-devops

# 创建deployment 和 service
kubectl apply -f ./kubectl-create.yml
```

集群搭建成功之后，在宿主机上 `curl http://localhost/orders/test`  就可以访问到 pod 中的服务了。我们也可以通过宿主机的公网 ip 访问到服务。

```sh
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.33.0.tar.gz
tar -xzvf ./git-2.33.0.tar.gz
```

### kind

Kind 是 Kubernetes In Docker 的缩写

```shell
# kind 安装 macos
brew install kind

# 安装 k8s 集群 ,--name 指定集群的名称,创建集群之后，默认会给创建 k8s 的 context
kind create cluster --name k8s-study

kind create cluster --name k8s-study2 --config ./k8s/cluster/multi-cluster.yml 

# 获取集群信息
kind get clusters

# 删除某个集群
kind delete cluster  --name k8s-study2
```

### kubectl

```shell
# ui 交互
brew install fzf

# k8s 上下文切换
brew install kubectx

# 设置 k8s 当前上下文中的默认 namespace
kubens

# 查看命令缩写，kubectl 对应的命令缩写
 alias
 
# 使用 kubectl 命令缩写
vim ~/.zshrc
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  kubectl
)
source ~/.zshrc
```

### 创建集群

### 创建 context 和 namespace

context 和 namespace 都是用于环境隔离的。

```shell
# 创建 namespace
kubectl create namespace fly-dev
```

### Deployment

Deployment controller 会根据 deployment 创建 rs 和 pod ,pod 中有一个容器。

```shell
# 创建或者更新 Deployment ,名称为 nginx-deployment
kubectl apply -f ./k8s/deployment/nginx/nginx.yml

# 查看 Deployment 的信息
kubectl describe deployment nginx-deployment
kdd nginx-deployment

# 查看历史 / 后面是 deployment 的名称
kubectl rollout history deployment/nginx-deployment

# 查看某个版本的历史详情，--to-revision 指定某个版本
kubectl rollout history deployment/nginx-deployment --revision=2

# 回退到某个版本，--to-revision 指定某个版本
kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

pod 生命周期较短，ip 会不断变化，引入 service，可以在集群内部通过域名访问，达到了负载均衡的效果。

### Service

在当前 namespace 下创建了 deployment 和 service。

```shell
# 在某个 pod 下访问，会通过 dns 解析路由到 selector: app: nginx2 标记到的 pod
curl nginx2-service 
```

```shell
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx2
  name: nginx2-service
spec:
  type: ClusterIP
  selector:
    app: nginx2
  ports:
    - name: nginx2
      port: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-node2
  labels:
    app: nginx2
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx2
  template:
    metadata:
      labels:
        app: nginx2
    spec:
      containers:
        - name: nginx2
          image: nginx:1.19.1
          ports:
            - containerPort: 80
EOF
```

### intergress

[nginx-ingress 操作](https://cloud.google.com/community/tutorials/nginx-ingress-gke)

当 cpu 和 内存不足时，集群是创建不成功的。而且 k8s 不支持 swap ，本地还可以玩玩。但是 aws 上免费的 ec2 无法支持玩 ingress，除非你愿意花钱，我是不愿意的，这个在本地玩玩就行了，如果在 EC2 想暴露 k8s
内部服务，建议使用 NodePort。

#### 创建 ingress 测试的集群

```shell
# 如果存在  nginx-ingress-cluster 先删除
kind delete clusters nginx-ingress-cluster

# 进入到 ./k8s/ingress 下面执行 run.sh 自动安装所需依赖

 # 最终会被转发到一个 pod 中 /foo 匹配不到资源，nginx 报错，但是已经可以从外部访问资源了。
 curl localhost/foo
```

### NodePort

通过将宿主机的 port 映射到 node 上的 port，service 配置与 node port 和 pod port 端口的映射。

我们通过访问宿主机上的 port 就可以访问到 port 上的服务。

#### 通过 kind 创建一个 node

这个 node 会和 宿主机上的 port 有一个映射。通过访问宿主机 80 端口，就可以访问到 node 中的 30000.

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: export-node-cluster
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000 # node 容器上的端口
    hostPort: 80 # 本地端口 80
```

#### 创建 deployment 部署 port

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-node
  namespace: fly-dev
  labels:
    app2: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.19.1
          ports:
            - containerPort: 80
```

#### 创建 service

service 会桥接 node 端口和 pod 端口映射

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx-service
  namespace: fly-dev
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - port: 80 # service 的端口
      targetPort: 80 # port 的端口
      nodePort: 30000 # 映射的 node 端口,取值范围 30000- ? 这个值不记得了
```

这样我们通过宿主机的端口 port 就可以访问到 pod 中的服务了。

#### 主从集群搭建

```shell
# 1.首先 用密钥登陆

#2.给 root 设置密码 
sudo passwd root

# 3.密码设置好后 切换到root用户 
su root

# 4.修改ssh配置文件，允许密码登录

# 将 passwordAuthentication no 改为  passwordAuthentication yes
# 将 PermitRootLogin 改为yes
vim /etc/ssh/sshd_config

# 重启sshd服务
sudo /sbin/service sshd restart


#su - jenkins一直有效，今天在centos发现无效，原因是

#/etc/password文件中的/bin/bash被yum安装的时候变成了/bin/false.


sudo -iu jenkins

# 生成秘钥
ssh-keygen -t rsa

ssh root@34.217.96.124 mkdir -p .ssh

# 将 master 上的公钥复制给 slave
cat .ssh/id_rsa.pub | ssh root@52.34.98.137 'cat >> .ssh/authorized_keys'
# 下载 slave
wget http://18.236.162.214:8080/jnlpJars/slave.jar
```

