# Makefile based on https://www.alexedwards.net/blog/a-time-saving-makefile-for-your-go-projects

all: help

## build: build the application
## docker image rm ubuntu-ubuntu -f
## make fresh
fresh:
	docker compose down
	docker image rm bandi13/gui-docker:firefox -f
	docker build -t bandi13/gui-docker:firefox -f Dockerfile.firefox .
	docker-compose up -d

## make st
st:
	docker compose up -d

