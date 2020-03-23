package test

import (
	"fmt"
	"path/filepath"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/stretchr/testify/assert"
)

//Create full_access group with admin permissions and config with MFA option
func TestIntegrationIAM2Groups(t *testing.T) {
	//1. Make this test case parallel which means it will not block other test cases
	t.Parallel()
	//2. Copy folder "../" to a tmp folder and return the tmp path of "examples"
	examplesFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples")
	iam_across_account_assistantFolder := filepath.Join(examplesFolder, "iam_across_account_assistant")

	//3. Create terraform options which is passed to terraform module
	expected_group_name := "full_access"
	expected_user_name := fmt.Sprintf("username-%s", random.UniqueId())
	user_groups := []map[string]interface{}{
		{
			"group_name": expected_group_name,
			"user_profiles": []map[string]interface{}{
				{
					//Use random.UniqueId() to make input value uniqued!
					"pgp_key":   "keybase:freshairfreshliv",
					"user_name": expected_user_name,
					"create_access_key": true,
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
		// Retry up to 3 times, with 5 seconds between retries, on known errors
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			"RequestError: send request failed": "Throttling issue?",
		},
	}

	//4. Something like finally in try...catch
	defer terraform.Destroy(t, terraformOptions)

	//5. Something like terraform init and terraform apply
	terraform.InitAndApply(t, terraformOptions)

	//6. Validate the created group
	iamClient := aws.NewIamClient(t, "us-east-2")

	resp, err := iamClient.GetGroup(&iam.GetGroupInput{
		GroupName: &expected_group_name,
	})
	if err != nil {
		return
	}
	actual_group_name := *resp.Group.GroupName
	assert.Equal(t, expected_group_name, actual_group_name, "These 2 groups should be the same.")
	actual_user_name := *resp.Users[0].UserName
	assert.Equal(t, expected_user_name, actual_user_name, "These 2 user names should be the same.")
}
