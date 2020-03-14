package test

import(
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
)

func TestAlbExample(t *testing.T) {
	fmt.Println()
	fmt.Println("If you see this text, it's working!")
	fmt.Println()
}

func TestIntegrationIAM2Groups(t *testing.T) {
	t.Parallel()
	testCouchbaseMultiCluster(t, "ubuntu", "enterprise")
}