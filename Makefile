RESULTS_PATH=/results

define copy_test_results
	## Obtains the results folder from within the stopped container and copies it to the local file system on the agent.
	container_id=$$(docker ps -a --no-trunc | grep apply-for-postgraduate-teacher-training | head -1 | cut -d ' ' -f1); \
	docker cp $$container_id:$(RESULTS_PATH)/ .
endef

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Create a new image
	touch .env ## Create an empty .env file if it doesn't exist
	docker-compose build

.PHONY: setup
setup: build ## Set up a clean database and node_modules folder for running the app or the specs in docker
	docker-compose down -v
	docker-compose run --rm web bundle exec rake db:setup

.PHONY: test
test: ## Run the linters and specs
	docker-compose run --rm web /bin/sh -c "bundle exec rake"

.PHONY: shell
shell: ## Open a shell on the app container
	docker-compose run --rm web ash

.PHONY: serve
serve: ## Run the service
	docker-compose up --build

.PHONY: ci.lint-ruby
ci.lint-ruby: ## Run Rubocop with results formatted for CI
	docker-compose run --rm web /bin/sh -c "bundle exec rubocop --format clang --parallel"

.PHONY: ci.lint-erb
ci.lint-erb: ## Run the ERB linter
	docker-compose run --rm web /bin/sh -c "bundle exec rake erblint"

.PHONY: ci.cucumber
ci.cucumber: ## Run the Cucumber specs
	-docker-compose run web /bin/sh -c 'mkdir $(RESULTS_PATH) && \
		bundle exec cucumber --format junit --out $(RESULTS_PATH)'
	$(call copy_test_results)
	docker-compose rm -f -v web

.PHONY: ci.test
ci.test: ## Run the tests with results formatted for CI
	docker-compose run web /bin/sh -c 'mkdir $(RESULTS_PATH) && \
		apk add nodejs yarn && \
		bundle exec rails assets:precompile && \
		bundle exec --verbose rspec --failure-exit-code 0 --format RspecJunitFormatter --out $(RESULTS_PATH)/rspec-results.xml'
	$(call copy_test_results)
	docker-compose rm -f -v web
