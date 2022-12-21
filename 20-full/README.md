# Simple module demo (for VPC creation)

This demo will take advantage of the [vpc module](https://github.com/terraform-aws-modules/terraform-aws-vpc) to create a fully-featured multi-az public/private VPC.

```
terraform init
terraform plan
terraform apply
```

```
terraform destroy
```




```
curl -sLO https://raw.githubusercontent.com/antonbabenko/terraform-cost-estimation/master/terraform.jq -O ../

terraform state pull | jq -cf ../terraform.jq | curl -s -X POST -H "Content-Type: application/json" -d @- https://cost.modules.tf/
```