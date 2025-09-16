# Azure Kubernetes Service / AKS cheatsheet

If you don't have access to AKS yet see [Developer on-boarding](/docs/developer-onboarding.md).

All examples below show qa usage and you should adapt accordingly.

## Authentication

### Raising a PIM request

You need to activate the group role in the desired cluster below:

<https://portal.azure.com/?Microsoft_Azure_PIMCommon=true&feature.msaljs=true#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/aadgroup/provider/aadgroup>

Example: Activate `*-teacher-services-cloud-test`. It will be approved automatically after a few seconds

### Azure setup

```sh
az login --use-device-code
```

Get access credentials for a managed Kubernetes cluster (passing the
environment name):

```sh
make qa get-cluster-credentials
```

## Show namespaces

```sh
kubectl get namespaces
```

## Show deployments

```sh
kubectl -n bat-qa get deployments
```

## Show pods

```sh
kubectl -n bat-qa get pods
```

## Get logs from a pod

Without tail:

```sh
kubectl -n bat-qa logs apply-qa-some-number
```

Tail:

```sh
kubectl -n bat-qa logs apply-qa-some-number -f
```

Logs from the ingress:

```sh
kubectl logs deployment/ingress-nginx-controller -f
```

Alternatively you can install kubetail and run:

```sh
kubetail -n bat-qa apply-qa-*
```

## Open a shell

```sh
kubectl -n bat-qa get deployments
kubectl -n bat-qa exec -ti deployment/apply-qa -- sh
```

Alternatively you can enter directly on a pod:

```sh
kubectl -n bat-qa exec -ti apply-qa-some-number -- sh
```

## Show CPU / Memory Usage

All pods in a namespace:

```sh
kubectl -n bat-qa top pod
```

All pods:

```sh
kubectl top pod -A
```

## More info on a pod

```sh
kubectl -n bat-qa describe pods apply-somenumber-of-the-pod
```

## Scaling

The app:

```sh
kubectl -n bat-qa scale deployment/apply-qa --replicas 2
```

The Nginx:

```sh
kubectl scale deployment/ingress-nginx-controller --replicas 2
```

### Enter on console

```sh
kubectl -n bat-qa exec -ti apply-qa-some-pod-number -- bundle exec rails c
```

### Running tasks

```sh
kubectl -n bat-qa exec -ti apply-qa-some-pod-number -- bundle exec rake -T
```

### Access the DB

```sh
make install-konduit
bin/konduit.sh -n bat-production -x apply-production -- psql
```

Example of accessing the database:

```sh
bin/konduit.sh apply-qa -- psql
```

## Using Makefile

To enter on a pod in QA using make:

```sh
make qa shell
```

And in production:

```sh
CONFIRM_PRODUCTION=true make production shell
```

Other environments:

```sh
make staging shell
make sandbox shell
```

In case you see this error:

```sh
User 'x' does not exist in MSAL token cache. Run `az login`.
```

Make sure you got the PIM approved first (then `az logout && az login` again).

## More info

For more info see
[Kubernetes cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
