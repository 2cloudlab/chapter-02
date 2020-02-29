terraform {
    required_version = "= 0.12.19"
}

resource "aws_cloudtrail" "trail" {
    name = var.trail_name
    s3_bucket_name = local.trail_event_s3_storage_name
}

resource "aws_s3_bucket" "trail_s3_storage" {
    count = var.is_trail_s3_storage_exist ? 0 : 1
    bucket = var.trail_event_s3_storage_name
}

locals {
    trail_event_s3_storage_name = var.is_trail_s3_storage_exist ? var.trail_event_s3_storage_name : aws_s3_bucket.trail_s3_storage[0].id
}