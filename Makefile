.PHONY: docker-down
docker-down:
	docker-compose down

.PHONY: docker-build
docker-build:
	docker-compose build

.PHONY: shell
shell: docker-down docker-build
	docker-compose run --rm web bash

.PHONY: db-setup
db-setup: docker-down docker-build
	docker-compose run --rm web bundle exec rails db:setup

.PHONY: test
test: docker-down docker-build db-setup
	docker-compose run --rm web bundle exec rspec

.PHONY: serve db-setup
serve: docker-down docker-build
	docker-compose up -d web
