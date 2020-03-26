terraform {
  required_version = "= 0.12.19"
}

provider "aws" {
  version = "= 2.46"
  region  = "us-east-2"
}

module "organization_cloudtrail" {
  source = "../../modules/cloudtrail"

  trail_name                  = "name_for_cloud_trail"
  trail_event_s3_storage_name = "global_unique_s3_name_2cloudlab"
  is_trail_s3_storage_exist   = false
}