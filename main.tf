
data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

module "vpc" {
  source = "./vpc"
  region = var.aws_region
}

resource "aws_route53_zone" "cluster_dns" {
  name          = var.domain_name
  force_destroy = true
}

resource "aws_ebs_encryption_by_default" "ebs_encryption" {
  enabled = true
}

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.12.0"

  node_security_group_additional_rules = {
    cluster_to_nginx_webhook = {
      description = "Cluster to ingress-nginx webhook"
      protocol    = "tcp"
      from_port   = 8443
      to_port     = 8443
      type        = "ingress"
      self        = true
    }
    cluster_to_load_balancer_controller_webhook = {
      description = "Cluster to load balancer controller webhook"
      protocol    = "tcp"
      from_port   = 9443
      to_port     = 9443
      type        = "ingress"
      self        = true
    }
  }
  # EKS CLUSTER
  cluster_name       = module.vpc.cluster_name
  cluster_version    = "1.23"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.vpc_private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    t3_medium = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.medium"]
      subnet_ids      = module.vpc.vpc_public_subnets

      disk_size = 50
    }
  }
}

resource "random_password" "grafana" {
  length  = 15
  special = false
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "grafana" {
  name_prefix             = "grafana-admin-password"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "grafana" {
  secret_id     = aws_secretsmanager_secret.grafana.id
  secret_string = random_password.grafana.result
}

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.12.0"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version
  eks_cluster_domain   = var.domain_name

  # EKS Managed Add-ons
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_amazon_eks_aws_ebs_csi_driver = true

  # Add-ons
  enable_aws_load_balancer_controller = true

  enable_external_dns = true
  external_dns_helm_config = {
    name       = "external-dns"
    chart      = "external-dns"
    repository = "https://charts.bitnami.com/bitnami"
    version    = "6.1.6"
    namespace  = "external-dns"
    values     = [templatefile("${path.module}/helm-values/external-dns-values.yaml", {})]
  }

  enable_ingress_nginx = true
  ingress_nginx_helm_config = {
    values = [templatefile("${path.module}/helm-values/nginx-values.yaml", {
      hostname = var.domain_name
    })]
  }

  enable_cert_manager = true
  cert_manager_helm_config = {
    set_values = [
      {
        name  = "extraArgs[0]"
        value = "--acme-http01-solver-nameservers=8.8.8.8:53\\,1.1.1.1:53"
      }
    ]
  }

  enable_prometheus = true
  enable_grafana    = true
  grafana_helm_config = {
    name        = "grafana"
    chart       = "grafana"
    repository  = "https://grafana.github.io/helm-charts"
    version     = "6.32.1"
    namespace   = "grafana"
    description = "Grafana Helm Chart deployment configuration"
    values = [
      templatefile(
        "${path.module}/helm-values/grafana-values.yaml.tpl",
        {
          hostname      = var.domain_name
        }
    )]
    set_sensitive = [
      {
        name  = "adminPassword"
        value = aws_secretsmanager_secret_version.grafana.secret_string
      }
    ]
  }

  enable_promtail = true
  promtail_helm_config = {
    name       = "promtail"
    repository = "https://grafana.github.io/helm-charts"
    chart      = "promtail"
    version    = "6.3.0"
    namespace  = "loki"
    values     = [templatefile("${path.module}/helm-values/promtail-values.yaml", {})]
  }

  depends_on = [aws_route53_zone.cluster_dns, helm_release.loki]
}

resource "helm_release" "loki" {
  name             = "loki-stack"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  namespace        = "loki"
  version          = "2.8.4"
  create_namespace = true
  values = [
    templatefile("${path.module}/helm-values/loki-stack-values.yaml",
      {

    })
  ]
  depends_on = [module.eks_blueprints]
}