# Makefile based on https://www.alexedwards.net/blog/a-time-saving-makefile-for-your-go-projects

all: help

## build: build the application
## docker image rm ubuntu-ubuntu -f
## make fresh
fresh:
	docker compose down
	docker image rm davidmadi/gui-docker:1.0 -f
	docker build -t davidmadi/gui-docker:1.0 -f Dockerfile.firefox .
	docker-compose up -d

## make st
st:
	docker compose up -d

hub:
	docker build -t davidmadi/gui-docker:1.0 -f Dockerfile.firefox .
	docker push davidmadi/gui-docker:1.0

