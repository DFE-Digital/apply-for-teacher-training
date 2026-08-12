ifndef VERBOSE
.SILENT:
endif

define debug
$(if $(VERBOSE),echo "$(1)")
endef

RSPEC_RESULTS_PATH=/rspec-results
INTEGRATION_TEST_PATTERN=spec/{system,requests}/**/*_spec.rb
COVERAGE_RESULT_PATH=/app/coverage
SERVICE_SHORT=att
SERVICE_NAME=apply
DB_TOOLS_POD_NAME=apply-$(CONFIG)-postgres-db-tools-pod
NAMESPACE = $(shell jq -r '.namespace' terraform/aks/workspace_variables/$(CONFIG).tfvars.json)

define copy_to_host
	## Obtains the results folder from within the stopped container and copies it to the local file system on the agent.
	container_id=$$(docker ps -a --no-trunc | grep apply-for-teacher-training | head -1 | cut -d ' ' -f1); \
	docker cp $$container_id:$(1)/ testArtifacts/
endef

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Create a new image
	touch .env ## Create an empty .env file if it does not exist
	docker-compose build

.PHONY: setup
setup: build ## Set up a clean database and node_modules folder for running the app or the specs in docker
	docker-compose down -v
	docker-compose up -d -V --no-build
	docker-compose exec web bundle exec rake db:setup
	docker-compose exec web apk add nodejs yarn

.PHONY: stop
stop: ## bring down the containers
	docker-compose down -v

.PHONY: test
test: ## Run the linters and specs
	docker-compose exec web /bin/sh -c "yarn install && bundle exec rake"

.PHONY: serve
serve: ## Run the service
	docker-compose up -V --build

.PHONY: lint-ruby
lint-ruby: ## Run Rubocop
	docker-compose run --rm web /bin/sh -c "bundle exec rubocop --format clang --parallel"

.PHONY: lint-erb
lint-erb: ## Run the ERB linter
	docker-compose run --rm web /bin/sh -c "bundle exec rake erb_lint"

.PHONY: brakeman
brakeman: ## Run Brakeman tests
	docker-compose run --rm web /bin/sh -c "bundle exec rake brakeman"

.PHONY: unit-tests
unit-tests: ## Run unit-tests
	docker-compose run --rm web /bin/sh -c "RAILS_ENV=test bundle exec rspec --exclude-pattern $(INTEGRATION_TEST_PATTERN)"

.PHONY: integration-tests
integration-tests: ## Run integraion-tests
	docker-compose run --rm web /bin/sh -c "RAILS_ENV=test bundle exec rspec --pattern $(INTEGRATION_TEST_PATTERN)"

.PHONY: install-fetch-config
install-fetch-config: ## Install the fetch-config script, for viewing/editing secrets in Azure Key Vault
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

.PHONY: install-konduit
install-konduit: ## Install the konduit script, for accessing backend services
	[ ! -f bin/konduit.sh ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/master/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh \
		|| true

domains:
	$(eval include global_config/apply-domain.sh)

pentest:
	$(eval APP_ENV=pentest)

review: test-cluster
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(eval include global_config/review.sh)
	$(eval APP_NAME_SUFFIX=review-$(PR_NUMBER))
	$(eval EXP_STORAGE_ACCOUNT_NAME=s189t01attexprv$(PR_NUMBER)sa)
	$(eval backend_key=-backend-config=key=pr-$(PR_NUMBER).tfstate)
	$(eval export TF_VAR_app_name_suffix=review-$(PR_NUMBER))
	$(eval export TF_VAR_exp_storage_account_name=s189t01attexprv$(PR_NUMBER)sa)

dv_review: dv_review-cluster ## make dv_review deploy PR_NUMBER=2222 CLUSTER=cluster1
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(if $(CLUSTER), , $(error Missing environment variable "CLUSTER", Please specify a dev cluster name (eg 'cluster1')))
	$(eval include global_config/dv_review.sh)
	$(eval APP_NAME_SUFFIX=dv-review-$(PR_NUMBER))
	$(eval backend_key=-backend-config=key=pr-$(PR_NUMBER).tfstate)
	$(eval export TF_VAR_app_name_suffix=review-$(PR_NUMBER))
	$(eval export TF_VAR_cluster=$(CLUSTER))

pt_review: test-cluster
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(if $(NAMESPACE), , $(error Missing environment variable "NAMESPACE", Please specify a namespace for your review app))
	$(eval include global_config/pt_review.sh)
	$(eval APP_NAME_SUFFIX=pt-review-$(PR_NUMBER))
	$(eval backend_key=-backend-config=key=pr-$(PR_NUMBER).tfstate)
	$(eval export TF_VAR_app_name_suffix=review-$(PR_NUMBER))
	$(eval export TF_VAR_namespace=$(NAMESPACE))
	$(if $(FD), $(eval export TF_VAR_gov_uk_host_names=["$(PR_NUMBER).apply-for-teacher-training.service.gov.uk","$(PR_NUMBER).apply-for-teacher-training.education.gov.uk"]))

qa: test-cluster
	$(eval include global_config/qa.sh)

staging: test-cluster
	$(eval include global_config/staging.sh)

sandbox: production-cluster
	$(eval include global_config/sandbox.sh)

production: production-cluster
	$(if $(or ${SKIP_CONFIRM}, ${CONFIRM_PRODUCTION}), , $(error Missing CONFIRM_PRODUCTION=yes))
	$(eval include global_config/production.sh)

ci:
	$(eval export AUTO_APPROVE=-auto-approve)
	$(eval export NO_IMAGE_TAG_DEFAULT=true)
	$(eval SKIP_CONFIRM=true)
	$(eval SKIP_AZURE_LOGIN=true)

# airbyte: ## Add airbyte for review apps
# 	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
# 	$(eval export TF_VAR_pg_airbyte_enabled=true)
# 	$(eval export TF_VAR_airbyte_enabled=true)
# 	$(eval export TF_VAR_connection_status=active)

set-azure-resource-group-tags: ##Tags that will be added to resource group on its creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early Years and Schools Group", "Parent Business":"Teacher Training and Qualifications", "Product" : "Apply for postgraduate teacher training", "Service Line": "Teaching Workforce", "Service": "Teacher services", "Service Offering": "Apply for postgraduate teacher training", "Environment" : "$(ENV_TAG)"}' | jq . ))

set-azure-template-tag:
	$(eval ARM_TEMPLATE_TAG=1.1.0)

set-azure-account:
	[ "${SKIP_AZURE_LOGIN}" != "true" ] && az account set -s ${AZURE_SUBSCRIPTION} || true

read-keyvault-config:
	$(eval KEY_VAULT_NAME=$(shell jq -r '.key_vault_name' terraform/$(PLATFORM)/workspace_variables/$(APP_ENV).tfvars.json))
	$(eval KEY_VAULT_APP_SECRET_NAME=$(shell jq -r '.key_vault_app_secret_name' terraform/$(PLATFORM)/workspace_variables/$(APP_ENV).tfvars.json))
	$(eval KEY_VAULT_INFRA_SECRET_NAME=$(shell jq -r '.key_vault_infra_secret_name' terraform/$(PLATFORM)/workspace_variables/$(APP_ENV).tfvars.json))

.PHONY: view-app-secrets
view-app-secrets: read-keyvault-config install-fetch-config set-azure-account ## View App Secrets, eg: make qa view-app-secrets
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_APP_SECRET_NAME} -f yaml

.PHONY: view-infra-secrets
view-infra-secrets: read-keyvault-config install-fetch-config set-azure-account ## View Infra Secrets, eg: make qa view-infra-secrets
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_INFRA_SECRET_NAME} -f yaml

.PHONY: edit-app-secrets
edit-app-secrets: read-keyvault-config install-fetch-config set-azure-account ## Edit App Secrets, eg: make qa edit-app-secrets
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_APP_SECRET_NAME} \
		-e -d azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_APP_SECRET_NAME} -f yaml -c

.PHONY: edit-infra-secrets
edit-infra-secrets: read-keyvault-config install-fetch-config set-azure-account ## Edit Infra Secrets, eg: make qa edit-infra-secrets
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_INFRA_SECRET_NAME} \
		-e -d azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_INFRA_SECRET_NAME} -f yaml -c

.PHONY: shell
shell: get-cluster-credentials ## Open a shell on the app instance on AKS, eg: make qa shell
	$(eval NAMESPACE=$(shell jq -r '.namespace' terraform/$(PLATFORM)/workspace_variables/$(APP_ENV).tfvars.json))
	$(eval APP_ENV=$(shell jq -r '.app_environment' terraform/$(PLATFORM)/workspace_variables/$(APP_ENV).tfvars.json))
	$(if ${APP_NAME_SUFFIX}, $(eval APP_NAME=apply-${APP_NAME_SUFFIX}-clock-worker), $(eval APP_NAME=apply-${APP_ENV}-clock-worker))
	kubectl -n ${NAMESPACE} -ti exec "deployment/${APP_NAME}" -- /bin/sh

.PHONY: console
console: get-cluster-credentials ## Open a Rails console on the app instance on AKS, eg: make qa console
	$(eval NAMESPACE=$(shell jq -r '.namespace' terraform/$(PLATFORM)/workspace_variables/$(APP_ENV).tfvars.json))
	$(eval APP_ENV=$(shell jq -r '.app_environment' terraform/$(PLATFORM)/workspace_variables/$(APP_ENV).tfvars.json))
	$(if ${APP_NAME_SUFFIX}, $(eval APP_NAME=apply-${APP_NAME_SUFFIX}-clock-worker), $(eval APP_NAME=apply-${APP_ENV}-clock-worker))
	kubectl -n ${NAMESPACE} -ti exec "deployment/${APP_NAME}" -- sh -c "cd /app && /usr/local/bin/bundle exec rails console -- --noautocomplete"

.PHONY: vendor-modules
vendor-modules:
	rm -rf terraform/aks/vendor/modules
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/aks/vendor/modules/aks

terraform-init: deploy-init

deploy-init: vendor-modules set-azure-account
	$(if $(or $(IMAGE_TAG), $(NO_IMAGE_TAG_DEFAULT)), , $(eval export IMAGE_TAG=main))
	$(if $(IMAGE_TAG), , $(error Missing environment variable "IMAGE_TAG"))
	$(eval export TF_VAR_docker_image=ghcr.io/dfe-digital/apply-teacher-training:$(IMAGE_TAG))
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

	terraform -chdir=terraform/$(PLATFORM) init -reconfigure -upgrade -backend-config=./workspace_variables/$(APP_ENV)_backend.tfvars $(backend_key)
	$(eval export TF_VAR_service_name=${SERVICE_NAME})

deploy-plan: deploy-init
	terraform -chdir=terraform/$(PLATFORM) plan ${DETAILED_EXITCODE} -var-file=./workspace_variables/$(APP_ENV).tfvars.json ${TF_VARS}

terraform-plan: deploy-plan

deploy: deploy-init
	terraform -chdir=terraform/$(PLATFORM) apply -var-file=./workspace_variables/$(APP_ENV).tfvars.json ${TF_VARS} $(AUTO_APPROVE)

terraform-destroy: destroy

destroy: deploy-init
	terraform -chdir=terraform/$(PLATFORM) destroy -var-file=./workspace_variables/$(APP_ENV).tfvars.json ${TF_VARS} $(AUTO_APPROVE)

set-what-if:
	$(eval WHAT_IF=--what-if)

check-auto-approve:
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))

arm-deployment: set-azure-account set-azure-template-tag set-azure-resource-group-tags
	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${SERVICE_SHORT}tfstate${CONFIG_SHORT}sa" "tfStorageContainerName=${SERVICE_SHORT}-tfstate" \
			"keyVaultName=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-kv" ${WHAT_IF}

deploy-azure-resources: check-auto-approve arm-deployment # make dev deploy-azure-resources AUTO_APPROVE=1

validate-azure-resources: set-what-if arm-deployment # make dev validate-azure-resources

domain-azure-resources: domains set-azure-account set-azure-template-tag set-azure-resource-group-tags #
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "${DNS_ZONE}domains-$(shell date +%Y%m%d%H%M%S)" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${DNS_ZONE}domainstf" "tfStorageContainerName=${DNS_ZONE}domains-tf"  "keyVaultName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-kv" ${WHAT_IF}

validate-domain-resources: set-what-if domain-azure-resources # make validate-domain-resources

deploy-domain-resources: check-auto-approve domain-azure-resources # make deploy-domain-resources AUTO_APPROVE=1

.PHONY: vendor-domain-infra-modules
vendor-domain-infra-modules:
	rm -rf terraform/custom_domains/infrastructure/vendor/modules/domains
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/custom_domains/infrastructure/vendor/modules/domains

domains-infra-init: domains vendor-domain-infra-modules set-azure-account
	terraform -chdir=terraform/custom_domains/infrastructure init -reconfigure -upgrade \
		-backend-config=workspace_variables/${DNS_ZONE}_backend.tfvars

domains-infra-plan: domains-infra-init # make domains-infra-plan
	terraform -chdir=terraform/custom_domains/infrastructure plan ${DETAILED_EXITCODE} -var-file workspace_variables/${DNS_ZONE}.tfvars.json

domains-infra-apply: domains-infra-init # make domains-infra-apply
	terraform -chdir=terraform/custom_domains/infrastructure apply -var-file workspace_variables/${DNS_ZONE}.tfvars.json ${AUTO_APPROVE}

.PHONY: vendor-domain-modules
vendor-domain-modules:
	rm -rf terraform/custom_domains/environment_domains/vendor/modules/domains
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/custom_domains/environment_domains/vendor/modules/domains

domains-init: domains vendor-domain-modules set-azure-account
	$(if $(PR_NUMBER), $(eval APP_ENV=${PR_NUMBER}))
	terraform -chdir=terraform/custom_domains/environment_domains init -upgrade -reconfigure -backend-config=workspace_variables/${DNS_ZONE}_${DNS_ENV}_backend.tfvars

domains-plan: domains-init  # make qa domains-plan
	terraform -chdir=terraform/custom_domains/environment_domains plan ${DETAILED_EXITCODE} -var-file workspace_variables/${DNS_ZONE}_${DNS_ENV}.tfvars.json

domains-apply: domains-init # make qa domains-apply
	terraform -chdir=terraform/custom_domains/environment_domains apply -var-file workspace_variables/${DNS_ZONE}_${DNS_ENV}.tfvars.json ${AUTO_APPROVE}

domains-destroy: domains-init # make qa domains-destroy
	terraform -chdir=terraform/custom_domains/environment_domains destroy -var-file workspace_variables/${DNS_ZONE}_${DNS_ENV}.tfvars.json

dv_review-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189d01-tsc-dv-rg)
	$(eval CLUSTER_NAME=s189d01-tsc-${CLUSTER}-aks)

test-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189t01-tsc-ts-rg)
	$(eval CLUSTER_NAME=s189t01-tsc-test-aks)

production-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189p01-tsc-pd-rg)
	$(eval CLUSTER_NAME=s189p01-tsc-production-aks)

get-cluster-credentials: set-azure-account
	az aks get-credentials --overwrite-existing -g ${CLUSTER_RESOURCE_GROUP_NAME} -n ${CLUSTER_NAME}
	kubelogin convert-kubeconfig -l $(if ${AAD_LOGIN_METHOD},${AAD_LOGIN_METHOD},azurecli)

maintenance-image-push: ## Build and push maintenance page image: make production maintenance-image-push GITHUB_TOKEN=x [MAINTENANCE_IMAGE_TAG=y]
	$(if ${GITHUB_TOKEN},, $(error Provide a valid Github token with write:packages permissions as GITHUB_TOKEN variable))
	$(if ${MAINTENANCE_IMAGE_TAG},, $(eval export MAINTENANCE_IMAGE_TAG=$(shell date +%s)))
	docker build -t ghcr.io/dfe-digital/apply-teacher-training-maintenance:${MAINTENANCE_IMAGE_TAG} maintenance_page
	echo ${GITHUB_TOKEN} | docker login ghcr.io -u USERNAME --password-stdin
	docker push ghcr.io/dfe-digital/apply-teacher-training-maintenance:${MAINTENANCE_IMAGE_TAG}

maintenance-fail-over: get-cluster-credentials ## Fail main app over to the maintenance page. Requires an existing maintenance docker image: make production maintenance-fail-over MAINTENANCE_IMAGE_TAG=y. See https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/maintenance-page.md#github-token
	$(eval export CONFIG)
	./maintenance_page/scripts/failover.sh

enable-maintenance: maintenance-image-push maintenance-fail-over ## Build, push, fail over: make production enable-maintenance GITHUB_TOKEN=x [MAINTENANCE_IMAGE_TAG=y]

disable-maintenance: get-cluster-credentials ## Fail back to the main app: make production disable-maintenance
	$(eval export CONFIG)
	./maintenance_page/scripts/failback.sh

composed-variables:
	$(eval RESOURCE_GROUP_NAME=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg)

set-pgserver:
	$(eval SERVERNAME=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG}-psql)
	echo "set-pgserver SERVERNAME: ${SERVERNAME}"

list-pglogs: composed-variables set-pgserver set-azure-account
	az postgres flexible-server server-logs list --resource-group ${RESOURCE_GROUP_NAME} --server-name ${SERVERNAME}

download-pglogs: composed-variables set-pgserver set-azure-account
	$(if $(LOG_NAME), , $(error Please specify a LOG_NAME for download))
	az postgres flexible-server server-logs download --name ${LOG_NAME} --resource-group ${RESOURCE_GROUP_NAME} --server-name ${SERVERNAME}
	ls -l $(LOG_NAME)*

enable-pglogs: composed-variables set-pgserver set-azure-account
	echo "Enabling server logs for PostgreSQL server ${SERVERNAME}"
	echo "Current Value"
	az postgres flexible-server parameter show --resource-group ${RESOURCE_GROUP_NAME} --server-name ${SERVERNAME} --name logfiles.download_enable --query value
	echo "Setting Value"
	az postgres flexible-server parameter set --resource-group ${RESOURCE_GROUP_NAME} --server-name ${SERVERNAME} --name logfiles.download_enable --value on
	echo "New Value"
	az postgres flexible-server parameter show --resource-group ${RESOURCE_GROUP_NAME} --server-name ${SERVERNAME} --name logfiles.download_enable --query value

disable-pglogs: composed-variables set-pgserver set-azure-account
	echo "Current Value"
	az postgres flexible-server parameter show --resource-group ${RESOURCE_GROUP_NAME} --server-name ${SERVERNAME} --name logfiles.download_enable --query value
	echo "Setting Value"
	az postgres flexible-server parameter set --resource-group ${RESOURCE_GROUP_NAME} --server-name ${SERVERNAME} --name logfiles.download_enable --value off
	echo "New Value"
	az postgres flexible-server parameter show --resource-group ${RESOURCE_GROUP_NAME} --server-name ${SERVERNAME} --name logfiles.download_enable --query value

show-service: get-cluster-credentials
	$(if $(PR_NUMBER), $(eval export DSUFFIX="-pr-${PR_NUMBER}"), $(eval export DSUFFIX="-${CONFIG}") )
	$(eval NAMESPACE=$(shell jq -r '.namespace' terraform/aks/workspace_variables/$(CONFIG).tfvars.json))
	echo "Show service deployments"
	kubectl -n ${NAMESPACE} get deployment/${SERVICE_NAME}${DSUFFIX}
	kubectl -n ${NAMESPACE} get deployment/${SERVICE_NAME}${DSUFFIX}-solid-queue-worker
	kubectl -n ${NAMESPACE} get deployment/${SERVICE_NAME}${DSUFFIX}-solid-queue-secondary-worker
	kubectl -n ${NAMESPACE} get deployment/${SERVICE_NAME}${DSUFFIX}-clock-worker

scale-app: get-cluster-credentials
	$(if $(PR_NUMBER), $(eval export DSUFFIX="-pr-${PR_NUMBER}"), $(eval export DSUFFIX="-${CONFIG}") )
	$(if $(REPLICAS),,$(error Missing REPLICAS))
	$(eval NAMESPACE=$(shell jq -r '.namespace' terraform/aks/workspace_variables/$(CONFIG).tfvars.json))
	echo "Scaling app to ${REPLICAS}"
	kubectl -n ${NAMESPACE} scale deployment/${SERVICE_NAME}${DSUFFIX} --replicas ${REPLICAS}

scale-workers: get-cluster-credentials
	$(if $(PR_NUMBER), $(eval export DSUFFIX="-pr-${PR_NUMBER}"), $(eval export DSUFFIX="-${CONFIG}") )
	$(if $(REPLICAS),,$(error Missing REPLICAS))
	$(eval NAMESPACE=$(shell jq -r '.namespace' terraform/aks/workspace_variables/$(CONFIG).tfvars.json))
	echo "Scaling workers to ${REPLICAS}"
	kubectl -n ${NAMESPACE} scale deployment/${SERVICE_NAME}${DSUFFIX}-solid-queue-worker --replicas ${REPLICAS}
	kubectl -n ${NAMESPACE} scale deployment/${SERVICE_NAME}${DSUFFIX}-solid-queue-secondary-worker --replicas ${REPLICAS}
	kubectl -n ${NAMESPACE} scale deployment/${SERVICE_NAME}${DSUFFIX}-clock-worker --replicas ${REPLICAS}

aks_db_job_backup: aks_db_job_check_single_pod aks_db_job_backup_action aks_db_job_kill_pods

aks_db_job_restore: aks_db_job_check_single_pod aks_db_job_restore_action aks_db_job_kill_pods

aks_db_job_interactive_new: aks_db_job_check_single_pod aks_db_job_set_common_vars aks_db_job_create_pod aks_db_job_interactive_join

aks_db_job_interactive_join:
	kubectl exec -it -n ${NAMESPACE} ${DB_TOOLS_POD_NAME} -- /bin/bash;

aks_db_job_set_common_vars: get-cluster-credentials
	$(if $(PR_NUMBER), $(eval export DSUFFIX="-pr-${PR_NUMBER}"), $(eval export DSUFFIX="-${CONFIG}") )
	$(eval DEPLOYMENT_NAME=${SERVICE_NAME}${DSUFFIX})
	#$(eval TODAY=$(shell date +"%F_%H%M%S"))
	$(eval STORAGE_ACCOUNT_NAME=${RESOURCE_NAME_PREFIX}${SERVICE_SHORT}dbbkp${CONFIG_SHORT}sa)
	$(eval CONTAINER_NAME=database-backup)
	$(eval SAS_VALID_HOURS="2")
	$(eval EXPIRY=$(shell date -u -d "+${SAS_VALID_HOURS} hours" +%Y-%m-%dT%H:%MZ))
	$(eval STORAGE_ACCOUNT_KEY=$(shell az storage account keys list --account-name "${STORAGE_ACCOUNT_NAME}" --query "[0].value" -o tsv))
	$(eval SAS_TOKEN=$(shell az storage container generate-sas --account-name "${STORAGE_ACCOUNT_NAME}" --account-key "${STORAGE_ACCOUNT_KEY}" --name "${CONTAINER_NAME}" --permissions acdlrw --expiry "${EXPIRY}" --https-only --output tsv))
	printf '%s' '$(SAS_TOKEN)' > sas_token.txt
	$(eval SECRET_REF_NAME := $(shell kubectl get deployment ${DEPLOYMENT_NAME} -n ${NAMESPACE} -o json | jq -r '.spec.template.spec.containers[].envFrom[]?.secretRef?.name // empty'))
	printf '%s' 'notset' > sas_url.txt

	$(call debug,"DSUFFIX: ${DSUFFIX}")
	$(call debug,"Namespace: ${NAMESPACE}")
	$(call debug,"DEPLOYMENT_NAME: ${DEPLOYMENT_NAME}")
	$(call debug,"STORAGE_ACCOUNT_NAME: ${STORAGE_ACCOUNT_NAME}")
	$(call debug,"CONTAINER_NAME: ${CONTAINER_NAME}")
	$(call debug,"TODAY: ${TODAY}")

aks_db_job_set_restore_vars: aks_db_job_set_common_vars
	$(if $(RESTORE_FILE), , $(error Missing environment variable "RESTORE_FILE", Please specify a file to restore from))
	$(eval SOURCE=https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${CONTAINER_NAME}/${RESTORE_FILE})
	$(eval SAS_URL=${SOURCE}?${SAS_TOKEN})
	printf '%s' '$(SAS_URL)' > sas_url.txt
	$(eval SECRET_REF_NAME := $(shell kubectl get deployment ${DEPLOYMENT_NAME} -n ${NAMESPACE} -o json | jq -r '.spec.template.spec.containers[].envFrom[]?.secretRef?.name // empty'))

	$(call debug,"SOURCE: ${SOURCE}")
	$(call debug,"RESTORE_FILE: ${RESTORE_FILE}")

aks_db_job_set_backup_vars: aks_db_job_set_common_vars
	$(eval JOB_NAME=postgres-backup-${TODAY})
	$(eval BACKUP_URL=https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${CONTAINER_NAME}/${JOB_NAME}.sql)
	$(eval SAS_URL=${BACKUP_URL}?${SAS_TOKEN})
	printf '%s' '$(SAS_URL)' > sas_url.txt
	$(eval SECRET_REF_NAME := $(shell kubectl get deployment ${DEPLOYMENT_NAME} -n ${NAMESPACE} -o json | jq -r '.spec.template.spec.containers[].envFrom[]?.secretRef?.name // empty'))
	$(call debug,"JOB_NAME: ${JOB_NAME}")

	$(call debug,"BACKUP_URL: ${BACKUP_URL}")
	$(call debug,"SECRET_REF_NAME: ${SECRET_REF_NAME}")

aks_db_job_create_pod:
	$(if $(SECRET_REF_NAME), , $(error Missing environment variable "SECRET_REF_NAME"))
	$(if $(DB_TOOLS_POD_NAME), , $(error Missing environment variable "DB_TOOLS_POD_NAME"))
	$(eval export SECRET_REF_NAME=$(SECRET_REF_NAME))
	$(eval export DB_TOOLS_POD_NAME=$(DB_TOOLS_POD_NAME))
	@if kubectl get secret backup-sas -n $(NAMESPACE) >/dev/null 2>&1; then \
		kubectl delete secret backup-sas -n $(NAMESPACE); \
	fi
	kubectl create secret -n $(NAMESPACE) generic backup-sas --from-file=AZURE_STORAGE_SAS_URL=sas_url.txt --from-file=AZURE_STORAGE_SAS_TOKEN=sas_token.txt;
	envsubst < db-pod/db-pod.yaml.tpl | kubectl apply -n ${NAMESPACE} -f -
	# allowing time for pod to startup...
	sleep 2s

aks_db_job_backup_action: aks_db_job_set_backup_vars aks_db_job_create_pod
	kubectl exec -it -n ${NAMESPACE} ${DB_TOOLS_POD_NAME} -- \
		/bin/bash -c '\
		cd /tmp && \
		echo "running pg_dump" && \
		pg_dump -d "$$DATABASE_URL" \
		-E utf8 \
		--clean \
		--compress=1 \
		--if-exists \
		--no-owner \
		--verbose \
		--no-password \
		-f pg_backup.gz && \
		echo "running azcopy" && \
		azcopy cp ./pg_backup.gz "$$AZURE_STORAGE_SAS_URL" \
	';

confirm:
	@read -p "This will restore and replace the database, do you want to Continue? [y/N] " answer; \
	if [ "$$answer" != "y" ]; then \
		echo "Aborted"; \
		exit 1; \
	fi
	@echo "Continuing..."


aks_db_job_restore_action: aks_db_job_set_restore_vars aks_db_job_create_pod confirm
	echo "aks_db_job_restore"
	kubectl exec -it -n $(NAMESPACE) ${DB_TOOLS_POD_NAME} -- \
		/bin/bash -c '\
		cd /tmp && \
		azcopy cp "$$AZURE_STORAGE_SAS_URL" ./pg_backup.gz && \
		gunzip -c pg_backup.gz | psql "$$DATABASE_URL" \
		'

aks_db_job_check_single_pod:
	@if kubectl get pod ${DB_TOOLS_POD_NAME} -n $(NAMESPACE) >/dev/null 2>&1; then \
		echo "Pod Already Exists, check ongoing activity -either kill with care! or join interatively with aks_db_job_interactive_join"; \
		exit 1; \
	fi

aks_db_job_kill_pods:
	@if kubectl get pod ${DB_TOOLS_POD_NAME} -n $(NAMESPACE) >/dev/null 2>&1; then \
		kubectl delete pod ${DB_TOOLS_POD_NAME} -n $(NAMESPACE); \
	fi
