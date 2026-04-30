start:
	docker compose up --build

build:
	docker compose build

console:
	docker compose run --rm web bin/rails console

bash:
	docker compose run --rm web bash

test:
	docker compose run --rm web bin/rails test

migrate: 
  docker compose run --rm web bin/rails db:migrate