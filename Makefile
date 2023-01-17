ifndef VERBOSE
.SILENT:
endif
RSPEC_RESULTS_PATH=/rspec-results
INTEGRATION_TEST_PATTERN=spec/{system,requests}/**/*_spec.rb
COVERAGE_RESULT_PATH=/app/coverage
SERVICE_SHORT=att

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

qa:
	$(eval APP_ENV=qa)
	$(eval SPACE=bat-qa)
	$(eval APP_NAME_SUFFIX=qa)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval ENV_TAG=Dev)

staging:
	$(eval APP_ENV=staging)
	$(eval SPACE=bat-staging)
	$(eval APP_NAME_SUFFIX=staging)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-test)
	$(eval ENV_TAG=Test)

sandbox:
	$(if $(CONFIRM_PRODUCTION), , $(error Production can only run with CONFIRM_PRODUCTION))
	$(eval APP_ENV=sandbox)
	$(eval SPACE=bat-prod)
	$(eval APP_NAME_SUFFIX=sandbox)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval ENV_TAG=Prod)

production:
	$(if $(CONFIRM_PRODUCTION), , $(error Production can only run with CONFIRM_PRODUCTION))
	$(eval APP_ENV=production)
	$(eval SPACE=bat-prod)
	$(eval APP_NAME_SUFFIX=prod)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval HOSTNAME=www)
	$(eval ENV_TAG=Prod)

review:
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(eval APP_ENV=review)
	$(eval SPACE=bat-qa)
	$(eval APP_NAME_SUFFIX=review-$(PR_NUMBER))
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval backend_key=-backend-config=key=pr-$(PR_NUMBER).tfstate)
	$(eval ENV_TAG=Dev)

	$(eval export TF_VAR_app_name_suffix=review-$(PR_NUMBER))
	echo Review app: https://apply-$(APP_NAME_SUFFIX).london.cloudapps.digital in bat-qa space

apply:
	$(eval DNS_ZONE=apply)
	$(eval APP_ENV=production)
	$(eval AZURE_SUBSCRIPTION=s189-teacher-services-cloud-production)
	$(eval RESOURCE_NAME_PREFIX=s189p01)
	$(eval ENV_SHORT=pd)
	$(eval ENV_TAG=Prod)

review_aks:
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(eval include global_config/review_aks.sh)
	$(eval APP_NAME_SUFFIX=review-$(PR_NUMBER))
	$(eval backend_key=-backend-config=key=pr-$(PR_NUMBER).tfstate)
	$(eval export TF_VAR_app_name_suffix=review-$(PR_NUMBER))

review_psp:
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(eval include global_config/review_psp.sh)
	$(eval APP_NAME_SUFFIX=review-$(PR_NUMBER))
	$(eval backend_key=-backend-config=key=pr-$(PR_NUMBER).tfstate)
	$(eval export TF_VAR_app_name_suffix=review-$(PR_NUMBER))

ci:
	$(eval export CONFIRM_DELETE=true)
	$(eval export DISABLE_PASSCODE=true)
	$(eval export AUTO_APPROVE=-auto-approve)
	$(eval export NO_IMAGE_TAG_DEFAULT=true)

loadtest:
	$(eval APP_ENV=loadtest)
	$(eval SPACE=bat-prod)
	$(eval APP_NAME_SUFFIX=loadtest)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval ENV_TAG=Prod)

set-azure-resource-group-tags: ##Tags that will be added to resource group on it's creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early Years and Schools Group", "Parent Business":"Teacher Training and Qualifications", "Product" : "Find postgraduate teacher training", "Service Line": "Teaching Workforce", "Service": "Teacher services", "Service Offering": "Find Postgraduate Teacher Training", "Environment" : "$(ENV_TAG)"}' | jq . ))

set-azure-template-tag:
	$(eval ARM_TEMPLATE_TAG=1.1.0)

set-azure-account:
	echo "Logging on to ${AZURE_SUBSCRIPTION}"
	az account set -s $(AZURE_SUBSCRIPTION)

read-deployment-config:
	$(eval export POSTGRES_DATABASE_NAME=apply-postgres-${APP_NAME_SUFFIX})

read-keyvault-config:
	$(eval KEY_VAULT_NAME=$(shell jq -r '.key_vault_name' terraform/workspace_variables/$(APP_ENV).tfvars.json))
	$(eval KEY_VAULT_APP_SECRET_NAME=$(shell jq -r '.key_vault_app_secret_name' terraform/workspace_variables/$(APP_ENV).tfvars.json))
	$(eval KEY_VAULT_INFRA_SECRET_NAME=$(shell jq -r '.key_vault_infra_secret_name' terraform/workspace_variables/$(APP_ENV).tfvars.json))

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
shell: ## Open a shell on the app instance on PaaS, eg: make qa shell
	cf target -s ${SPACE}
	cf ssh apply-clock-${APP_NAME_SUFFIX} -t -c 'cd /app && /usr/local/bin/bundle exec rails console -- --noautocomplete'

deploy-init:
	$(if $(or $(IMAGE_TAG), $(NO_IMAGE_TAG_DEFAULT)), , $(eval export IMAGE_TAG=main))
	$(if $(IMAGE_TAG), , $(error Missing environment variable "IMAGE_TAG"))
	$(if $(or $(DISABLE_PASSCODE),$(PASSCODE)), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	$(eval export TF_VAR_paas_sso_code=$(PASSCODE))
	$(eval export TF_VAR_paas_docker_image=ghcr.io/dfe-digital/apply-teacher-training:$(IMAGE_TAG))

	az account set -s $(AZURE_SUBSCRIPTION) && az account show
	cd terraform && terraform init -reconfigure -backend-config=workspace_variables/$(APP_ENV)_backend.tfvars $(backend_key)

deploy-plan: deploy-init
	cd terraform && terraform plan -var-file=workspace_variables/$(APP_ENV).tfvars.json

deploy: deploy-init
	cd terraform && terraform apply -var-file=workspace_variables/$(APP_ENV).tfvars.json $(AUTO_APPROVE)

destroy: deploy-init
	cd terraform && terraform destroy -var-file=workspace_variables/$(APP_ENV).tfvars.json $(AUTO_APPROVE)

.PHONY: delete-clock
delete-clock:
	$(if $(CONFIRM_DELETE), , $(error delete-clock can only run with CONFIRM_DELETE))
	cf delete -f "apply-clock-${APP_NAME_SUFFIX}"

.PHONY: set-space-developer
set-space-developer: ## make qa set-space-developer USER_ID=first.last@digital.education.gov.uk
	$(if $(USER_ID), , $(error Missing environment variable "USER_ID", USER_ID required for this command to run))
	cf set-space-role $(USER_ID) dfe $(SPACE) SpaceDeveloper

.PHONY: unset-space-developer
unset-space-developer: ## make qa unset-space-developer USER_ID=first.last@digital.education.gov.uk
	$(if $(USER_ID), , $(error Missing environment variable "USER_ID", USER_ID required for this command to run))
	cf unset-space-role $(USER_ID) dfe $(SPACE) SpaceDeveloper

.PHONY: stop-all-apps
stop-all-apps: ## Stops web, clock and worker apps, make qa stop-all-apps CONFIRM_STOP=1
	$(if $(CONFIRM_STOP), , $(error stop-all-apps can only run with CONFIRM_STOP))
	cf target -s ${SPACE}
	cf stop apply-${APP_NAME_SUFFIX} && \
	cf stop apply-clock-${APP_NAME_SUFFIX} && \
	cf stop apply-worker-${APP_NAME_SUFFIX}

.PHONY: get-image-tag
get-image-tag: ## make qa get-image-tag
	$(eval export TAG=$(shell cf target -s ${SPACE} 1> /dev/null && cf app apply-${APP_NAME_SUFFIX} | awk -F : '$$1 == "docker image" {print $$3}'))
	@echo ${TAG}

.PHONY: get-postgres-instance-guid
get-postgres-instance-guid: ## Gets the postgres service instance's guid
	cf target -s ${SPACE} > /dev/null
	cf service apply-postgres-${APP_NAME_SUFFIX} --guid

.PHONY: rename-postgres-service
rename-postgres-service: ## make qa rename-postgres-service NEW_NAME_SUFFIX=backup CONFIRM_RENAME=y
	$(if $(CONFIRM_RENAME), , $(error can only run with CONFIRM_RENAME))
	$(if $(NEW_NAME_SUFFIX), , $(error NEW_NAME_SUFFIX is required))
	cf target -s ${SPACE} > /dev/null
	cf rename-service apply-postgres-${APP_NAME_SUFFIX} apply-postgres-${APP_NAME_SUFFIX}-$(NEW_NAME_SUFFIX)

.PHONY: remove-postgres-tf-state
remove-postgres-tf-state: deploy-init ## make qa remove-postgres-tf-state PASSCODE=
	cd terraform && terraform state rm module.paas.cloudfoundry_service_instance.postgres && \
	  terraform state rm module.paas.cloudfoundry_service_key.postgres-readonly-key

.PHONY: restore-postgres
restore-postgres: deploy-init ## make qa restore-postgres DB_INSTANCE_GUID="<cf service db-name --guid>" BEFORE_TIME="" IMAGE_TAG=<COMMIT_SHA> PASSCODE=<auth code from https://login.london.cloud.service.gov.uk/passcode>
	cf target -s ${SPACE} > /dev/null
	$(if $(DB_INSTANCE_GUID), , $(error can only run with DB_INSTANCE_GUID, get it by running `make ${SPACE} get-postgres-instance-guid`))
	$(if $(BEFORE_TIME), , $(error can only run with BEFORE_TIME, eg BEFORE_TIME="2021-09-14 16:00:00"))
	$(eval export TF_VAR_paas_restore_db_from_db_instance=$(DB_INSTANCE_GUID))
	$(eval export TF_VAR_paas_restore_db_from_point_in_time_before=$(BEFORE_TIME))
	echo "Restoring apply-postgres-${APP_NAME_SUFFIX} from $(TF_VAR_paas_restore_db_from_db_instance) before $(TF_VAR_paas_restore_db_from_point_in_time_before)"
	make ${APP_ENV} deploy

enable-maintenance: ## make qa enable-maintenance / make production enable-maintenance CONFIRM_PRODUCTION=y
	$(if $(HOSTNAME), $(eval REAL_HOSTNAME=${HOSTNAME}), $(eval REAL_HOSTNAME=${APP_ENV}))
	cf target -s ${SPACE}
	cd service_unavailable_page && cf push
	cf map-route apply-unavailable apply-for-teacher-training.service.gov.uk --hostname ${REAL_HOSTNAME}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route apply-${APP_ENV} apply-for-teacher-training.service.gov.uk --hostname ${REAL_HOSTNAME}

disable-maintenance: ## make qa disable-maintenance / make production disable-maintenance CONFIRM_PRODUCTION=y
	$(if $(HOSTNAME), $(eval REAL_HOSTNAME=${HOSTNAME}), $(eval REAL_HOSTNAME=${APP_ENV}))
	cf target -s ${SPACE}
	cf map-route apply-${APP_ENV} apply-for-teacher-training.service.gov.uk --hostname ${REAL_HOSTNAME}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route apply-unavailable apply-for-teacher-training.service.gov.uk --hostname ${REAL_HOSTNAME}
	cf delete -rf apply-unavailable

restore-data-from-nightly-backup: read-deployment-config read-keyvault-config # make production restore-data-from-nightly-backup CONFIRM_PRODUCTION=YES CONFIRM_RESTORE=YES BACKUP_DATE="yyyy-mm-dd"
	bin/download-nightly-backup APPLY-BACKUP-STORAGE-CONNECTION-STRING ${KEY_VAULT_NAME} ${APP_NAME_SUFFIX}-db-backup apply_${APP_NAME_SUFFIX}_ ${BACKUP_DATE}
	$(if $(CONFIRM_RESTORE), , $(error Restore can only run with CONFIRM_RESTORE))
	bin/restore-nightly-backup ${SPACE} ${POSTGRES_DATABASE_NAME} apply_${APP_NAME_SUFFIX}_ ${BACKUP_DATE}

domain-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags# make domain domain-azure-resources AUTO_APPROVE=1
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "${DNS_ZONE}domains" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${DNS_ZONE}domainstf" "tfStorageContainerName=${DNS_ZONE}domains-tf"  "keyVaultName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-kv"

dnszone-init: set-azure-account
	echo "Setting up DNS zone for $(DNS_ZONE) in subscription $(AZURE_SUBSCRIPTION)"
	az account show
	cd dns/zones && terraform init -backend-config workspace-variables/backend_${DNS_ZONE}.tfvars -upgrade -reconfigure

dnszone-plan: dnszone-init
	cd dns/zones && terraform plan -var-file workspace-variables/${DNS_ZONE}-zone.tfvars.json

dnszone-apply: dnszone-init
	cd dns/zones && terraform apply -var-file workspace-variables/${DNS_ZONE}-zone.tfvars.json ${AUTO_APPROVE}

dnsrecord-init: set-azure-account
	$(if $(DNS_ENV), , $(error must supply domain environment DNS_ENV))
	echo "Setting up DNS for $(DNS_ZONE) $(DNS_ENV) in subscription $(AZURE_SUBSCRIPTION)"
	az account show
	cd dns/records && terraform init -backend-config workspace-variables/backend_${DNS_ZONE}_${DNS_ENV}.tfvars -upgrade -reconfigure

dnsrecord-plan: dnsrecord-init
	cd dns/records && terraform plan -var-file workspace-variables/${DNS_ZONE}_${DNS_ENV}.tfvars.json

dnsrecord-apply: dnsrecord-init
	cd dns/records && terraform apply -var-file workspace-variables/${DNS_ZONE}_${DNS_ENV}.tfvars.json ${AUTO_APPROVE}
set-what-if:
	$(eval WHAT_IF=--what-if)

check-auto-approve:
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))

set-azure-template-tag:
	$(eval ARM_TEMPLATE_TAG=1.0.0)

set-azure-resource-group-tags: ##Tags that will be added to resource group on its creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early Years and Schools Group", "Parent Business":"Teacher Training and Qualifications", "Product" : "Apply for postgraduate teacher training", "Service Line": "Teaching Workforce", "Service": "Teacher Training and Qualifications", "Service Offering": "Apply for postgraduate teacher training", "Environment" : "$(ENV_TAG)"}' | jq . ))

arm-deployment: azure-login set-azure-template-tag set-azure-resource-group-tags
	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${SERVICE_SHORT}tfstate${CONFIG_SHORT}sa" "tfStorageContainerName=${SERVICE_SHORT}-tfstate" \
			"keyVaultName=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-kv" ${WHAT_IF}

deploy-azure-resources: check-auto-approve arm-deployment # make dev deploy-azure-resources AUTO_APPROVE=1

validate-azure-resources: set-what-if arm-deployment # make dev validate-azure-resources
