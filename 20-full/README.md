# Complete stack demo

This demo deploys an application using the classic ALB + ASG + RDS stack, properly configured.
It is designed to facilitate learning about several Terraform features, like:

* The use of resources and modules
* Applying input and output parameters
* Overwriting input parameters for production using a file
* Properly chaining Security Groups to ensure traffic segregation
* Finding the current LTS version of Ubuntu AMI
* Applying the user data from a separate file
* Storing the (random) database password in a parameter store secure string

## Preparation

*Note*: CloudShell is not the best environment to run critical processes, and it is even worst if you don't
keep your Terraform backend secured on S3. In case you get any problem executing the commands



* Open [CloudShell](https://us-east-1.console.aws.amazon.com/cloudshell/home?region=us-east-1) to get a Linux prompt

* Install the `terraform` command

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

terraform version
```

* Get the source code of the workshop and move the prompt to the correct directory

```bash
git clone https://github.com/ciberado/terraform-workshop.git
cd terraform-workshop/20-full/src/
```

## Deployment

* Download the dependencies

```bash
terraform init
```

* Validate the code and plan the changes (take a close look to the proposed actions)

```bash
terraform validate
terraform plan -var-file prod.tfvars -var prefix=$USER
```

## Security checking: Checkov

* Install [Checkov](https://www.checkov.io/), one of the best Infrastructure as Code audit tool

```bash
python3 -m pip install checkov
```

* Scan for configuration bad practices

```bash
checkov -d .
```

## Security checking: AquaSecurity

* Install the [AquaSecurity](https://github.com/aquasecurity/tfsec) tool

```bash
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
```

* Run the checking!

```bash
tfsec --tfvars-file prod.tfvars .
```

## Infrastructure deployment

* Launch the the infrastructure. It will take around 15 minutes to set it up everything properly

```bash
terraform apply -var-file=prod.tfvars -auto-approve
```

* Get the address of the load balancer and open it with your browser

```bash
echo http://$(terraform output -raw app_alb_fqdn); echo
```

*Note: even if the infrastructure has been completely deploye, it will still require a few
minutes to be available, as the application installation process is not optimized.*

## Cleanup

* Delete the infrastructure

```bash
terraform apply -destroy -var-file=prod.tfvars -auto-approve
```
