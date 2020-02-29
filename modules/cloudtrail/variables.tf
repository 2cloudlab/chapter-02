variable "trail_name" {
    description = "trail name"
    type = string
}

variable "trail_event_s3_storage_name" {
    description = "s3 name"
    type = string
}

variable "is_trail_s3_storage_exist"{
    description = "set fasle to create s3 bucket for storing trail events"
    type = bool
    default = false
}