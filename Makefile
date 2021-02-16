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
	docker-compose run --rm web bundle exec rake db:setup

.PHONY: az_setup
az_setup: ## Set up a clean database and node_modules folder for running the app or the specs in docker
	touch .env ## Create an empty .env file if it does not exist
	docker-compose run --rm web bundle exec rake db:setup

.PHONY: test
test: ## Run the linters and specs
	docker-compose run --rm web /bin/sh -c "bundle exec rake"

.PHONY: shell
shell: ## Open a shell on the app container
	docker-compose run --rm web ash

.PHONY: serve
serve: ## Run the service
	docker-compose up -V --build

.PHONY: ci.lint-ruby
ci.lint-ruby: ## Run Rubocop with results formatted for CI
	docker-compose run --rm web /bin/sh -c "bundle exec rubocop --format clang --parallel"

.PHONY: ci.lint-erb
ci.lint-erb: ## Run the ERB linter
	docker-compose run --rm web /bin/sh -c "bundle exec rake erblint"

.PHONY: ci.brakeman
ci.brakeman: ## Run Brakeman tests
	docker-compose run --rm web /bin/sh -c "bundle exec rake brakeman"

.PHONY: ci.unit-tests
ci.unit-tests: ## Run the tests with results formatted for CI
	docker-compose run web /bin/sh -c 'mkdir $(RSPEC_RESULTS_PATH) && \
		bundle exec --verbose rspec --exclude-pattern $(INTEGRATION_TEST_PATTERN) --failure-exit-code 0 --format RspecJunitFormatter --out $(RSPEC_RESULTS_PATH)/rspec-unit-tests-results.xml'
	$(call copy_to_host,$(RSPEC_RESULTS_PATH))
	$(call copy_to_host,$(COVERAGE_RESULT_PATH))
	docker-compose rm -f -v web

.PHONY: ci.integration-tests
ci.integration-tests: ## Run the tests with results formatted for CI
	docker-compose run web /bin/sh -c 'mkdir $(RSPEC_RESULTS_PATH) && \
		bundle exec --verbose rspec --pattern $(INTEGRATION_TEST_PATTERN) --failure-exit-code 0 --format RspecJunitFormatter --out $(RSPEC_RESULTS_PATH)/rspec-integration-tests-results.xml'
	$(call copy_to_host,$(RSPEC_RESULTS_PATH))
	$(call copy_to_host,$(COVERAGE_RESULT_PATH))
	docker-compose rm -f -v web
