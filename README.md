<!-- BEGIN_TF_DOCS -->
## Init :
```
terraform init
terraform plan
terraform apply
```

## Clean up :
```
terraform destroy -target="module.eks_blueprints_kubernetes_addons.module.ingress_nginx[0].module.helm_addon.helm_release.addon[0]" --auto-approve
terraform destroy -target="module.eks_blueprints_kubernetes_addons.module.ingress_nginx[0].kubernetes_namespace_v1.this[0]" --auto-approve
terraform destroy -target="module.eks_blueprints_kubernetes_addons.module.prometheus[0].module.helm_addon.helm_release.addon[0]" --auto-approve
terraform destroy -target="module.eks_blueprints_kubernetes_addons.module.prometheus[0].kubernetes_namespace_v1.prometheus[0]" --auto-approve
terraform destroy -target="module.eks_blueprints" --auto-approve
terraform destroy -target="module.vpc" --auto-approve
terraform destroy --auto-approve
```

## Go test :
```
go test -v test_test.go -run TestExamplesBasicTest -timeout 40m
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.35 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.7.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.16.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.3 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.46.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.7.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_blueprints"></a> [eks\_blueprints](#module\_eks\_blueprints) | github.com/aws-ia/terraform-aws-eks-blueprints | v4.12.0 |
| <a name="module_eks_blueprints_kubernetes_addons"></a> [eks\_blueprints\_kubernetes\_addons](#module\_eks\_blueprints\_kubernetes\_addons) | github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons | v4.12.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ebs_encryption_by_default.ebs_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_route53_zone.cluster_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_secretsmanager_secret.grafana](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.grafana](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [helm_release.loki](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [random_password.grafana](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region name | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_route53_zone"></a> [aws\_route53\_zone](#output\_aws\_route53\_zone) | Route53 Hosted Zone ID |
| <a name="output_aws_route53_zone_name_servers"></a> [aws\_route53\_zone\_name\_servers](#output\_aws\_route53\_zone\_name\_servers) | Route53 Hosted Zone Nameservers |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Kubernetes Cluster Name |
| <a name="output_cluster_vpc_id"></a> [cluster\_vpc\_id](#output\_cluster\_vpc\_id) | VPC ID |
| <a name="output_grafana_admin_password"></a> [grafana\_admin\_password](#output\_grafana\_admin\_password) | Grafana admin password |
| <a name="output_region"></a> [region](#output\_region) | AWS region where the cluster is provisioned |
| <a name="output_vpc_private_subnets"></a> [vpc\_private\_subnets](#output\_vpc\_private\_subnets) | VPC private subnets |
| <a name="output_vpc_public_subnets"></a> [vpc\_public\_subnets](#output\_vpc\_public\_subnets) | VPC public subnets |
<!-- END_TF_DOCS -->