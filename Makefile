# Makefile based on https://www.alexedwards.net/blog/a-time-saving-makefile-for-your-go-projects

# 1st, login
## aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 580425214548.dkr.ecr.us-west-2.amazonaws.com
# deploy until aws_ecr_repository
# push image
# deploy until the end

all: help

## build: build the application
## docker image rm ubuntu-ubuntu -f
## make fresh
fresh:
	docker compose down
	docker image rm gui_docker:latest -f
	docker build -t gui_docker:latest --platform linux/amd64 -f Dockerfile.firefox .
	docker-compose up -d

## make st
st:
	docker compose up -d

hub:
	docker tag gui_docker:latest 580425214548.dkr.ecr.us-west-2.amazonaws.com/gui_docker:latest
	docker push 580425214548.dkr.ecr.us-west-2.amazonaws.com/gui_docker:latest

## export AWS_ACCESS_KEY_ID=
## export AWS_SECRET_ACCESS_KEY=

terra:
	terraform init
	terraform plan -destroy
	terraform fmt
	terraform validate
	terraform apply
	terraform destroy
	terraform show
	terraform state list