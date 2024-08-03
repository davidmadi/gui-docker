# GUI Docker on AWS
## Starting up
```
export AWS_SECRET_ACCESS_KEY=<TOKEN>
export AWS_ACCESS_KEY_ID=<TOKEN>
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <USERID>.dkr.ecr.us-east-1.amazonaws.com/gui_docker
```
## Terraform
1. Comment after and Deploy until aws_ecr_repository (main.tf)
```
cd terraform
terraform plan
terraform apply
```
## Push image
```
cd ..
make push
```
2. Uncomment and deploy the rest (run multiple times if needed)
```
cd terraform
terraform plan
terraform apply
```

## Shuting off
```
terraform plan -destroy
terraform destroy
```
Remove manually if needed
