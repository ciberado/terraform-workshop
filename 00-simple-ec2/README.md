# Launching an EC2 instance

* Initialize the providers

```
terraform init
```

* Format the code (just for your own pleasure)

```
terraform fmt
```

* Validate the sintax

```
terraform validate
```

* Check the variables for test environment

```
cat variables.tf
cat test.tfvars
```

* Beam me up, Scotty!

```
terraform apply -var-file=test.tfvars
```

* Check the created resources

```
terraform state list
```

* Check the result of the execution

```
cat terraform.state
terraform show
```

* Show the webpage url

```
IP=$(terraform output -raw ip) && echo http://$IP:8080
```

* Clean up everything

```
terraform destroy
```
