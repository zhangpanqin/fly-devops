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

#### 创建 ingress 测试的集群

```shell
# 如果存在  nginx-ingress-cluster 先删除
kind delete clusters nginx-ingress-cluster

# 进入到 ./k8s/ingress 下面执行 run.sh 自动安装所需依赖

 # 最终会被转发到一个 pod 中 /foo 匹配不到资源，nginx 报错，但是已经可以从外部访问资源了。
 curl localhost/foo
```

