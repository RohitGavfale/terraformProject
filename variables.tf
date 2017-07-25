variable "count" {
  default = "1"
}
variable "count_format" {
  default = "%02d"
}
variable "image_id" {
  description = "Please provide the proper image_id"
}

variable "availability_zones" {
  default = ""
}

variable "role" {
  default = "work"
}
variable "datacenter" {
  default = "beijing"
}
variable "short_name" {
  description = "Please provide the proper name for instance"
}
variable "ecs_type" {
  default = "ecs.n1.small"
}
variable "ecs_password" {
  description = "Please provide the proper password for root connection"
}
variable "allocate_public_ip" {
  default = true
}
variable "internet_charge_type" {
  default = "PayByTraffic"
}
variable "internet_max_bandwidth_out" {
  default = 5
}

variable "disk_category" {
  default = "cloud_efficiency"
}
variable "disk_size" {
  default = "40"
}

variable "nic_type" {
  default = "internet"
}

variable "source_dir" {
  description = "Please provide the proper path where the file is store"
}

variable "access_key" {
  default = "LTAIXxxy0N7R5Po3"
}

variable "secret_key" {
  default = "YzCZ5ddJkSPySIDUj8OfXjWatn0sQ6"
}
