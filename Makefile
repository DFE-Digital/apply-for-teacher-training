.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Create a new image
	docker-compose build

.PHONY: setup
setup: build ## Set up a clean database for running the app or the specs in docker
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
	docker-compose run --rm web /bin/sh -c "bundle exec govuk-lint-ruby app config db lib spec --format clang"

.PHONY: ci.lint-erb
ci.lint-erb: ## Run the ERB linter
	docker-compose run --rm web /bin/sh -c "bundle exec rake lint_erb"

.PHONY: ci.test
ci.test: ## Run the tests with results formatted for CI
	docker-compose run --rm web /bin/sh -c 'bundle exec rspec --format RspecJunitFormatter' > rspec-results.xml

