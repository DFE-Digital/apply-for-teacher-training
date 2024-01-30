# Azure Kubernetes Service / AKS cheatsheet

If you don't have access to AKS yet see [Developer on-boarding](/docs/developer-onboarding.md).

All examples below show qa usage and you should adapt accordingly.

## Authentication

### Raising a PIM request

You need to activate the role in the desired cluster below:
https://portal.azure.com/?Microsoft_Azure_PIMCommon=true#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/azurerbac

Example: Activate `*-teacher-services-cloud-test`. It will be approved automatically after a few seconds

### Azure setup

```
$ az login
```

Get access credentials for a managed Kubernetes cluster (passing the
environment name):

```
$ make qa_aks get-cluster-credentials
```

## Show namespaces

```
$ kubectl get namespaces
```

## Show deployments

```
$ kubectl -n bat-qa get deployments
```

## Show pods

```
$ kubectl -n bat-qa get pods
```

## Get logs from a pod

Without tail:

```
$ kubectl -n bat-qa logs apply-qa-some-number
```

Tail:

```
$ kubectl -n bat-qa logs apply-qa-some-number -f
```

Logs from the ingress:

```
$ kubectl logs deployment/ingress-nginx-controller -f
```

Alternatively you can install kubetail and run:

```
$ kubetail -n bat-qa apply-qa-*
```

## Open a shell

```
$ kubectl -n bat-qa get deployments
$ kubectl -n bat-qa exec -ti deployment/apply-loadtest -- sh
```

Alternatively you can enter directly on a pod:

```
$ kubectl -n bat-qa exec -ti apply-qa-some-number -- sh
```

## Show CPU / Memory Usage

All pods in a namespace:
```
kubectl -n bat-qa top pod
```

All pods:
```
kubectl top pod -A
```

## More info on a pod

```
$ kubectl -n bat-qa describe pods apply-somenumber-of-the-pod
```

## Scaling

The app:
```
$ kubectl -n bat-qa scale deployment/apply-loadtest --replicas 2
```

The Nginx:

```
$ kubectl scale deployment/ingress-nginx-controller --replicas 2
```

### Enter on console

```
kubectl -n bat-qa exec -ti apply-loadtest-some-pod-number -- bundle exec rails c
```


### Running tasks

```
kubectl -n bat-qa exec -ti apply-loadtest-some-pod-number -- bundle exec rake -T
```

### Access the DB

```
make install-konduit
bin/konduit.sh app-name -- psql
```

Example of loading test:

```
bin/konduit.sh apply-loadtest -- psql
```

## Using Makefile

To enter on a pod in QA using make:

```
make qa shell
```

And in production:
```
make production shell
```

Other environments:

```
make staging shell
make sandbox shell
```

In case you see this error:

```
User 'x' does not exist in MSAL token cache. Run `az login`.
```

Make sure you got the PIM approved first (then `az logout && az login` again).

## More info

For more info see
[Kubernetes cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
