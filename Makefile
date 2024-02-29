ifndef VERBOSE
.SILENT:
endif
RSPEC_RESULTS_PATH=/rspec-results
INTEGRATION_TEST_PATTERN=spec/{system,requests}/**/*_spec.rb
COVERAGE_RESULT_PATH=/app/coverage
SERVICE_SHORT=att
SERVICE_NAME=apply
TERRAFILE_VERSION=0.8

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
	docker-compose run --rm web /bin/sh -c "bundle exec rake erblint"

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

apply:
	$(eval include global_config/apply-domain.sh)
	$(eval DNS_ZONE=apply)
	$(eval APP_ENV=production)
	$(eval AZURE_SUBSCRIPTION=s189-teacher-services-cloud-production)
	$(eval RESOURCE_NAME_PREFIX=s189p01)
	$(eval ENV_SHORT=pd)
	$(eval ENV_TAG=Prod)

pentest:
	$(eval APP_ENV=pentest)

review_aks: test-cluster
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(eval include global_config/review_aks.sh)
	$(eval APP_NAME_SUFFIX=review-$(PR_NUMBER))
	$(eval backend_key=-backend-config=key=pr-$(PR_NUMBER).tfstate)
	$(eval export TF_VAR_app_name_suffix=review-$(PR_NUMBER))

dv_review_aks: test-cluster ## make dv_review_aks deploy PR_NUMBER=2222 CLUSTER=cluster1
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(if $(CLUSTER), , $(error Missing environment variable "CLUSTER", Please specify a dev cluster name (eg 'cluster1')))
	$(eval include global_config/dv_review_aks.sh)
	$(eval APP_NAME_SUFFIX=dv-review-$(PR_NUMBER))
	$(eval backend_key=-backend-config=key=pr-$(PR_NUMBER).tfstate)
	$(eval export TF_VAR_app_name_suffix=review-$(PR_NUMBER))
	$(eval export TF_VAR_cluster=$(CLUSTER))

pt_review_aks: test-cluster
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(if $(NAMESPACE), , $(error Missing environment variable "NAMESPACE", Please specify a namespace for your review app))
	$(eval include global_config/pt_review_aks.sh)
	$(eval APP_NAME_SUFFIX=pt-review-$(PR_NUMBER))
	$(eval backend_key=-backend-config=key=pr-$(PR_NUMBER).tfstate)
	$(eval export TF_VAR_app_name_suffix=review-$(PR_NUMBER))
	$(eval export TF_VAR_namespace=$(NAMESPACE))
	$(if $(FD), $(eval export TF_VAR_gov_uk_host_names=["$(PR_NUMBER).apply-for-teacher-training.service.gov.uk","$(PR_NUMBER).apply-for-teacher-training.education.gov.uk"]))

loadtest_aks: test-cluster
	$(eval include global_config/loadtest_aks.sh)

qa_aks: test-cluster
	$(eval include global_config/qa_aks.sh)

staging_aks: test-cluster
	$(eval include global_config/staging_aks.sh)

sandbox_aks: production-cluster
	$(eval include global_config/sandbox_aks.sh)

production_aks: production-cluster
	$(if $(or ${SKIP_CONFIRM}, ${CONFIRM_PRODUCTION}), , $(error Missing CONFIRM_PRODUCTION=yes))
	$(eval include global_config/production_aks.sh)

qa: qa_aks
staging: staging_aks
sandbox: sandbox_aks
production: production_aks

ci:
	$(eval export AUTO_APPROVE=-auto-approve)
	$(eval export NO_IMAGE_TAG_DEFAULT=true)
	$(eval SKIP_CONFIRM=true)

set-azure-resource-group-tags: ##Tags that will be added to resource group on its creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early Years and Schools Group", "Parent Business":"Teacher Training and Qualifications", "Product" : "Apply for postgraduate teacher training", "Service Line": "Teaching Workforce", "Service": "Teacher services", "Service Offering": "Apply for postgraduate teacher training", "Environment" : "$(ENV_TAG)"}' | jq . ))

set-azure-template-tag:
	$(eval ARM_TEMPLATE_TAG=1.1.0)

set-azure-account:
	echo "Logging on to ${AZURE_SUBSCRIPTION}"
	az account set -s $(AZURE_SUBSCRIPTION)

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
	$(if ${APP_NAME_SUFFIX}, $(eval APP_NAME=apply-clock-worker-${APP_NAME_SUFFIX}), $(eval APP_NAME=apply-clock-worker-${APP_ENV}))
	kubectl -n ${NAMESPACE} -ti exec "deployment/${APP_NAME}" -- sh -c "cd /app && /usr/local/bin/bundle exec rails console -- --noautocomplete"

deploy-init: bin/terrafile
	$(if $(or $(IMAGE_TAG), $(NO_IMAGE_TAG_DEFAULT)), , $(eval export IMAGE_TAG=main))
	$(if $(IMAGE_TAG), , $(error Missing environment variable "IMAGE_TAG"))
	$(eval export TF_VAR_docker_image=ghcr.io/dfe-digital/apply-teacher-training:$(IMAGE_TAG))
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

	az account set -s $(AZURE_SUBSCRIPTION) && az account show
	./bin/terrafile -p terraform/aks/vendor/modules -f terraform/aks/workspace_variables/$(CONFIG)_Terrafile
	terraform -chdir=terraform/$(PLATFORM) init -reconfigure -upgrade -backend-config=./workspace_variables/$(APP_ENV)_backend.tfvars $(backend_key)
	$(eval export TF_VAR_service_name=${SERVICE_NAME})

deploy-plan: deploy-init
	terraform -chdir=terraform/$(PLATFORM) plan -var-file=./workspace_variables/$(APP_ENV).tfvars.json ${TF_VARS}

deploy: deploy-init
	terraform -chdir=terraform/$(PLATFORM) apply -var-file=./workspace_variables/$(APP_ENV).tfvars.json ${TF_VARS} $(AUTO_APPROVE)

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

set-production-subscription:
	$(eval AZURE_SUBSCRIPTION=s189-teacher-services-cloud-production)

domain-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags #
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "${DNS_ZONE}domains-$(shell date +%Y%m%d%H%M%S)" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${DNS_ZONE}domainstf" "tfStorageContainerName=${DNS_ZONE}domains-tf"  "keyVaultName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-kv" ${WHAT_IF}

validate-domain-resources: set-what-if domain-azure-resources # make apply validate-domain-resources

deploy-domain-resources: check-auto-approve domain-azure-resources # make apply deploy-domain-resources AUTO_APPROVE=1

domains-infra-init: set-production-subscription set-azure-account
	terraform -chdir=terraform/custom_domains/infrastructure init -reconfigure -upgrade \
		-backend-config=workspace_variables/${DOMAINS_ID}_backend.tfvars

domains-infra-plan: domains-infra-init # make apply domains-infra-plan
	terraform -chdir=terraform/custom_domains/infrastructure plan -var-file workspace_variables/${DOMAINS_ID}.tfvars.json

domains-infra-apply: domains-infra-init # make apply domains-infra-apply
	terraform -chdir=terraform/custom_domains/infrastructure apply -var-file workspace_variables/${DOMAINS_ID}.tfvars.json ${AUTO_APPROVE}

domains-init: set-production-subscription set-azure-account
	$(if $(PR_NUMBER), $(eval APP_ENV=${PR_NUMBER}))
	terraform -chdir=terraform/custom_domains/environment_domains init -upgrade -reconfigure -backend-config=workspace_variables/${DOMAINS_ID}_${DNS_ENV}_backend.tfvars

domains-plan: domains-init  # make apply qa domains-plan
	terraform -chdir=terraform/custom_domains/environment_domains plan -var-file workspace_variables/${DOMAINS_ID}_${DNS_ENV}.tfvars.json

domains-apply: domains-init # make apply qa domains-apply
	terraform -chdir=terraform/custom_domains/environment_domains apply -var-file workspace_variables/${DOMAINS_ID}_${DNS_ENV}.tfvars.json ${AUTO_APPROVE}

domains-destroy: domains-init # make apply qa domains-destroy
	terraform -chdir=terraform/custom_domains/environment_domains destroy -var-file workspace_variables/${DOMAINS_ID}_${DNS_ENV}.tfvars.json

test-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189t01-tsc-ts-rg)
	$(eval CLUSTER_NAME=s189t01-tsc-test-aks)

production-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189p01-tsc-pd-rg)
	$(eval CLUSTER_NAME=s189p01-tsc-production-aks)

get-cluster-credentials: set-azure-account
	az aks get-credentials --overwrite-existing -g ${CLUSTER_RESOURCE_GROUP_NAME} -n ${CLUSTER_NAME}
	kubelogin convert-kubeconfig -l $(if ${GITHUB_ACTIONS},spn,azurecli)

bin/terrafile: ## Install terrafile to manage terraform modules
	curl -sL https://github.com/coretech/terrafile/releases/download/v${TERRAFILE_VERSION}/terrafile_${TERRAFILE_VERSION}_$$(uname)_x86_64.tar.gz \
		| tar xz -C ./bin terrafile
