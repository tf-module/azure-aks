# Terraform Create Azure AKS

Terraform Create Azure AKS cluster, configure helm, aci-connector

## 1. Create RABC Role for aks service:

```shell
az ad sp create-for-rbac --role="Contributor" --name="K8S-Dev" --scopes="/subscriptions/{your_subscription_id}"
```

## 2. Export environment varibles in console:

```shell
#Used for azurerm provider, visit: https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html
export ARM_CLIENT_ID=xxx
export ARM_CLIENT_SECRET=xxx
export ARM_SUBSCRIPTION_ID=xxx
export ARM_TENANT_ID=xxx

#The following varibles are used for AKS service principle
export TF_VAR_K8S_CLUSTER_NAME=xxx
export TF_VAR_K8S_CLIENT_ID=xxx
export TF_VAR_K8S_CLIENT_SECRET=xxx

```

## 3. Run terraform command

```shell
terraform init
terraform apply
```

## 4. Configure k8s for helm

```shell
aks get-credentials --name {your cluster name} --resource-group {your resource group name}
kubectl config use-context {your cluster name)
kubectl apply -f manifests/helm-rbac.yaml
```

## 5. Install ingress controller

```shell
helm install stable/nginx-ingress \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
```

## 6. A demo to deploy an application

```shell
kubectl apply -f manifests/deployment.yaml
```