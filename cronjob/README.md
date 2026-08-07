# Using AKS Jobs to run DB Backups

Deploy the template
```
kubectl apply -f postgres-backup-template.yaml
```

Trigger a manual Backup
```
kubectl create job \
  --from=cronjob/postgres-backup-template \
  postgres-backup-$(date +%s) \
  -n development
```

Trigger using buildID from github
```
kubectl create job \
  --from=cronjob/postgres-backup-template \
  postgres-backup-${BUILD_BUILDID} \
  -n development
```

Watch progress
```
kubectl get jobs -n development
kubectl logs -f job/postgres-backup-1785485746 -n development
```

Pass a temporary secret
```
kubectl create secret generic test-secret \
  --from-literal=DATABASE_URL='postgres://user:pass@host/db' \
  -n development
```


kubectl run postgres-backup-debug \
  -n development \
  --image=ghcr.io/dfe-digital/teacher-services-cloud-db-backup:2911-postgres-backup-via-aks \
  --restart=Never \
  --command -- sleep infinity


kubectl delete pod postgres-backup-debug -n development
kubectl apply -f debug-pod.yaml
kubectl exec -it -n development postgres-backup-debug -- /bin/bash

## Testing

### Working in dev cluster 4
make dv_review deploy PR_NUMBER=rdg CLUSTER=cluster4 IMAGE_TAG=7d883255c8e657b54d919f67811d27b9202723fd 2>&1 | tee tf-apply.txt

make dv_review terraform-plan PR_NUMBER=rdg CLUSTER=cluster4 IMAGE_TAG=7d883255c8e657b54d919f67811d27b9202723fd 2>&1 | tee tf-apply.txt


export DB_BACKUP_IMAGE_TAG=$(date +%s)
make dv_review show-service PR_NUMBER=rdg CLUSTER=cluster4

kubectl create job --from=cronjob/postgres-backup-template postgres-backup-$(date +%s) -n development

docker build -f Dockerfile.db-backup -t ghcr.io/dfe-digital/apply-teacher-training-test-db-backup:202607310949 .

docker push ghcr.io/dfe-digital/apply-teacher-training-test-db-backup:202607310949



dv_review-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189d01-tsc-dv-rg)
	$(eval CLUSTER_NAME=s189d01-tsc-cluster4-aks)

az aks get-credentials --overwrite-existing -g s189d01-tsc-dv-rg -n s189d01-tsc-cluster4-aks
kubelogin convert-kubeconfig -l azurecli



	POSTGRES_HOST
	POSTGRES_USER
	POSTGRES_DB
	STORAGE_ACCOUNT
	CONTAINER
	BACKUP_NAME
	SAS_TOKEN
