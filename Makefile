ifndef VERBOSE
.SILENT:
endif
RSPEC_RESULTS_PATH=/rspec-results
INTEGRATION_TEST_PATTERN=spec/{system,requests}/**/*_spec.rb
COVERAGE_RESULT_PATH=/app/coverage

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

staging:
	$(eval APP_ENV=staging)
	$(eval SPACE=bat-staging)
	$(eval APP_NAME_SUFFIX=staging)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-test)

sandbox:
	$(if $(CONFIRM_SANDBOX), , $(error Production can only run with CONFIRM_SANDBOX))
	$(eval APP_ENV=sandbox)
	$(eval SPACE=bat-prod)
	$(eval APP_NAME_SUFFIX=sandbox)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)

prod:
	$(if $(CONFIRM_PRODUCTION), , $(error Production can only run with CONFIRM_PRODUCTION))
	$(eval APP_ENV=production)
	$(eval APP_NAME_SUFFIX=prod)
	$(eval SPACE=bat-prod)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval HOSTNAME=www)

research:
	$(eval APP_ENV=research)
	$(eval APP_NAME_SUFFIX=research)
	$(eval SPACE=bat-qa)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)

load-test:
	$(eval APP_ENV=loadtest)
	$(eval APP_NAME_SUFFIX=load-test)
	$(eval SPACE=bat-qa)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)

azure-login:
	az account set -s $(AZURE_SUBSCRIPTION)

.PHONY: view-app-secrets
view-app-secrets: install-fetch-config azure-login ## View App Secrets, eg: make qa view-app-secrets
	bundle exec dotenv -f terraform/workspace_variables/$(APP_ENV).tfvars bin/fetch_config.rb -s azure-key-vault-secret -f yaml

.PHONY: view-infra-secrets
view-infra-secrets: install-fetch-config azure-login ## View Infra Secrets, eg: make qa view-infra-secrets
	bundle exec dotenv -f terraform/workspace_variables/$(APP_ENV).tfvars bin/fetch_config.rb -t infra -s azure-key-vault-secret -f yaml

.PHONY: edit-app-secrets
edit-app-secrets: install-fetch-config azure-login ## Edit App Secrets, eg: make qa edit-app-secrets
	bundle exec dotenv -f terraform/workspace_variables/$(APP_ENV).tfvars bin/fetch_config.rb -s azure-key-vault-secret -f yaml -e -d azure-key-vault-secret -c

.PHONY: edit-infra-secrets
edit-infra-secrets: install-fetch-config azure-login ## Edit Infra Secrets, eg: make qa edit-infra-secrets
	bundle exec dotenv -f terraform/workspace_variables/$(APP_ENV).tfvars bin/fetch_config.rb -t infra -s azure-key-vault-secret -f yaml -e -d azure-key-vault-secret -c

.PHONY: shell
shell: ## Open a shell on the app instance on PaaS, eg: make qa shell
	cf target -s ${SPACE}
	cf ssh apply-clock-${APP_NAME_SUFFIX} -t -c 'cd /app && /usr/local/bin/bundle exec rails c'

deploy-init:
	$(if $(IMAGE_TAG), , $(error Please pass a valid docker image tag; eg: make qa deploy-init IMAGE_TAG=5309326123bf6b366deab6cd0668615d11be3e3d))
	$(eval export TF_VAR_paas_docker_image=ghcr.io/dfe-digital/apply-teacher-training:$(IMAGE_TAG))
	$(if $(PASSCODE), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	$(eval export TF_VAR_paas_sso_code=$(PASSCODE))
	az account set -s $(AZURE_SUBSCRIPTION) && az account show \
	&& cd terraform && terraform init -reconfigure -backend-config=workspace_variables/$(APP_ENV)_backend.tfvars

deploy-plan: deploy-init
	cd terraform && terraform plan -var-file=workspace_variables/$(APP_ENV).tfvars

deploy: deploy-init
	cd terraform && terraform apply -var-file=workspace_variables/$(APP_ENV).tfvars

destroy: deploy-init
	cd terraform && terraform destroy -var-file=workspace_variables/$(APP_ENV).tfvars

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

.PHONY: get-postgres-instance-guid
get-postgres-instance-guid: ## Gets the postgres service instance's guid
	cf target -s ${SPACE} > /dev/null
	cf service apply-postgres-${APP_NAME_SUFFIX} --guid

.PHONY: rename-postgres-service
rename-postgres-service: ## make qa rename-postgres-service NEW_NAME_SUFFIX=apply-postgres-qa-backup CONFIRM_RENAME
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

enable-maintenance: ## make qa enable-maintenance / make prod enable-maintenance CONFIRM_PRODUCTION=y
	$(if $(HOSTNAME), $(eval REAL_HOSTNAME=${HOSTNAME}), $(eval REAL_HOSTNAME=${APP_ENV}))
	cf target -s ${SPACE}
	cd service_unavailable_page && cf push
	cf map-route apply-unavailable apply-for-teacher-training.service.gov.uk --hostname ${REAL_HOSTNAME}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route apply-${APP_ENV} apply-for-teacher-training.service.gov.uk --hostname ${REAL_HOSTNAME}

disable-maintenance: ## make qa disable-maintenance / make prod disable-maintenance CONFIRM_PRODUCTION=y
	$(if $(HOSTNAME), $(eval REAL_HOSTNAME=${HOSTNAME}), $(eval REAL_HOSTNAME=${APP_ENV}))
	cf target -s ${SPACE}
	cf map-route apply-${APP_ENV} apply-for-teacher-training.service.gov.uk --hostname ${REAL_HOSTNAME}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route apply-unavailable apply-for-teacher-training.service.gov.uk --hostname ${REAL_HOSTNAME}
	cf delete -rf apply-unavailable
