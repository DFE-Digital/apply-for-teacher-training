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
	$(eval SPACE_SUFFIX=qa)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)

staging:
	$(eval APP_ENV=staging)
	$(eval SPACE_SUFFIX=staging)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-test)

sandbox:
	$(eval APP_ENV=sandbox)
	$(eval SPACE_SUFFIX=prod)
	$(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)

prod:
  $(eval APP_ENV=production)
  $(eval SPACE_SUFFIX=prod)
  $(eval AZURE_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)

azure-login:
	az account set -s $(AZURE_SUBSCRIPTION)

.PHONY: view-app-secrets
view-app-secrets: install-fetch-config azure-login ## View App Secrets, eg: make qa view-app-secrets
	bundle exec dotenv -f terraform/workspace_variables/$(APP_ENV).tfvars bin/fetch_config.rb -s azure-key-vault-secret -f yaml

.PHONY: edit-app-secrets
edit-app-secrets: install-fetch-config azure-login ## Edit App Secrets, eg: make qa edit-app-secrets
	bundle exec dotenv -f terraform/workspace_variables/$(APP_ENV).tfvars bin/fetch_config.rb -s azure-key-vault-secret -f yaml -e -d azure-key-vault-secret -c

.PHONY: shell
shell: ## Open a shell on the app instance on PaaS, eg: make qa shell
	cf target -s bat-${SPACE_SUFFIX}
	cf ssh apply-clock-${SPACE_SUFFIX} -t -c 'cd /app && /usr/local/bin/bundle exec rails c'
