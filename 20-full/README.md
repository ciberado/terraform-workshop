# Complete stack demo

This demo deploys an application using the classic ALB + ASG + RDS stack, properly configured.
It is designed to facilitate several Terraform features, like:

* The use of resources and modules
* Applying input and output parameters
* Overwriting input parameters for production using a file
* Properly chaining Security Groups to ensure traffic segregation
* Activating VPC flow logs
* The configuration of AMI Roles for computation
* Finding the current LTS version of Ubuntu AMI
* Applying the user data from a separate file
* Storing the (random) database password in a parameter store secure string

## Simple usage

* Create a workspace

```bash
terraform workspace new development
terraform workspace select development # Not actually needed
```

* Validate, plan and apply the changes

```bash
terraform validate
terraform plan
terraform apply
```

* Calculate the cost of the main resources in the solution

```bash
terraform state pull | \
  jq -cf ./clean-sensible-data.jq | \
  curl -s -X POST \
    -H "Content-Type: application/json" \
    -d @- https://cost.modules.tf/ \
; echo
```

* Delete everything once finished

```bash
terraform destroy
```

## Production environment

* Create a workspace

```bash
terraform workspace new production
terraform workspace select production # Not actually needed
```

* Validate, plan and apply the changes

```bash
terraform validate
terraform plan
terraform apply -var-file="prod.tfvars"
```

* Delete everything once finished

```bash
terraform destroy
```
