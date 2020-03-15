package test

import (
	"fmt"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestIntegrationIAM2Groups(t *testing.T) {
	//Make this test case parallel which means it will not block other test cases
	t.Parallel()
	//Copy folder "../" to a tmp folder and return the tmp path of "examples"
	examplesFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples")
	iam_across_account_assistantFolder := filepath.Join(examplesFolder, "iam_across_account_assistant")

	//Create terraform options which is passed to terraform module
	user_groups := []map[string]interface{}{
		{
			"group_name": "full_access",
			"user_profiles": []map[string]interface{}{
				{
					//Use random.UniqueId() to make input value uniqued!
					"pgp_key":   fmt.Sprintf("pgp-%s", random.UniqueId()),
					"user_name": fmt.Sprintf("username-%s", random.UniqueId()),
				},
			},
		},
	}
	terraformOptions := &terraform.Options{
		TerraformDir: iam_across_account_assistantFolder,
		Vars: map[string]interface{}{
			"should_require_mfa": true,
			"user_groups":        user_groups,
		},
	}

	//Something like finally in try...catch
	defer terraform.Destroy(t, terraformOptions)

	//Something like terraform init and terraform apply
	terraform.InitAndApply(t, terraformOptions)
}
