.PHONY: build
build:
	docker-compose build

.PHONY: setup
setup: build
	docker-compose down -v
	docker-compose run --rm web bundle exec rake db:setup

.PHONY: test
test:
	docker-compose run --rm web /bin/sh -c "bundle exec rake"

.PHONY: shell
shell:
	docker-compose run --rm web ash

.PHONY: serve
serve:
	docker-compose up --build
	
