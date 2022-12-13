package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestExamplesBasicTest(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "./",
		Vars: map[string]interface{}{
			"aws_region":                   "eu-central-1",
			"domain_name":                  "testdomain.com",
		},
	}

	// Destroy order
	modules := []string{
		"module.eks_blueprints_kubernetes_addons.module.ingress_nginx[0].module.helm_addon.helm_release.addon[0]",
		"module.eks_blueprints_kubernetes_addons.module.ingress_nginx[0].kubernetes_namespace_v1.this[0]",
		"module.eks_blueprints_kubernetes_addons.module.prometheus[0].module.helm_addon.helm_release.addon[0]", // Properly delete Prometheus dynamic PVC
		"module.eks_blueprints_kubernetes_addons.module.prometheus[0].kubernetes_namespace_v1.prometheus[0]",
		"module.eks_blueprints_kubernetes_addons",
		"module.eks_blueprints",
		"module.vpc",
		"destroy",
	}

	defer test_structure.RunTestStage(t, "destroy", func() {
		for _, target := range modules {
			clusterName := terraform.Output(t, terraformOptions, "cluster_name")
			if target != "destroy" {
				terraformOptions := &terraform.Options{
					TerraformDir: "./",
					Vars: map[string]interface{}{
						"aws_region":                   "eu-central-1",
						"domain_name":                  "testdomain.com",
					},
					Targets: []string{target},
				}

				terraform.Destroy(t, terraformOptions)
				time.Sleep(10 * time.Second)
			} else {
				// Clean remaining EKS CloudWatch log group.
				fmt.Println("Cleaning " + clusterName + " CloudWatch Log group")
				sess, _ := session.NewSession(&aws.Config{
					Region: aws.String("eu-central-1"),
				})
				client := cloudwatchlogs.New(sess)
				get := &cloudwatchlogs.DeleteLogGroupInput{
					LogGroupName: aws.String("/aws/eks/" + clusterName + "/cluster"),
				}
				_, err := client.DeleteLogGroup(get)
				if err != nil {
					fmt.Println(err)
				}
				terraform.Destroy(t, terraformOptions)
			}
		}
	})

	terraform.InitAndApply(t, terraformOptions)
}
