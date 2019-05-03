.PHONY: db-setup
db-setup: docker-down docker-build
	docker-compose run --rm web bundle exec rails db:setup

.PHONY: docker-down
docker-down:
	docker-compose down

.PHONY: docker-build
docker-build:
	docker-compose build

.PHONY: lint
lint: docker-down docker-build
	docker-compose run --rm web bundle exec rubocop app config db lib spec Gemfile

.PHONY: shell
shell: docker-down docker-build db-setup
	docker-compose run --rm web bash

.PHONY: test
test: docker-down docker-build db-setup
	docker-compose run --rm web bundle exec rspec

.PHONY: serve
serve: docker-down docker-build db-setup
	docker-compose up -d web
