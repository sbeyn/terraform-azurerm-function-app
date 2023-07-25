package test

import (
    _"fmt"
    "io/ioutil"
    "os"
    "path/filepath"
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestEndToEndDeploymentScenario(t *testing.T) {

    fixtureFolder := "../examples/default"

    // Configure a plan file path so we can introspect the plan and make assertions about it.
    planOutFile := "plan.out"

    // Variables to pass to our Terraform code using -var options
    vars := map[string]interface{}{
              "tenant_id": os.Getenv("ARM_TENANT_ID"),
              "subscription_id": os.Getenv("ARM_SUBSCRIPTION_ID"),
              "client_id": os.Getenv("ARM_CLIENT_ID"),
              "client_secret": os.Getenv("ARM_CLIENT_SECRET"),
    }

    // User Terratest to deploy the infrastructure
    test_structure.RunTestStage(t, "create", func() {

        terraformPlanOptions := &terraform.Options{
            TerraformDir: fixtureFolder,
            Vars: vars,
            PlanFilePath: planOutFile,
        }

        // Show and save output json
        jsonOut := terraform.InitAndPlanAndShow(t, terraformPlanOptions)
        ioutil.WriteFile(filepath.Join(fixtureFolder, "plan.out.json"), []byte(jsonOut), 0644)

        terraformOptions := &terraform.Options{
            TerraformDir: fixtureFolder,
            Vars: vars,
            Parallelism: 1,
        }

        // Save options for later test stages
        test_structure.SaveTerraformOptions(t, fixtureFolder, terraformOptions)

        // Triggers the terraform init and terraform apply command
        terraform.InitAndApply(t, terraformOptions)
    })

    test_structure.RunTestStage(t, "idempotence", func() {

        terraformOptions := test_structure.LoadTerraformOptions(t, fixtureFolder)

        // Triggers to check Terraform configuration is idempotent when a second apply results in 0 changes
        terraform.ApplyAndIdempotent(t, terraformOptions)
    })


    // When the test is completed, destroy the infrastructure by calling terraform destroy
    test_structure.RunTestStage(t, "destroy", func() {

        terraformOptions := test_structure.LoadTerraformOptions(t, fixtureFolder)

        // Triggers the terraform destroy command
        defer terraform.Destroy(t, terraformOptions)
    })
}

