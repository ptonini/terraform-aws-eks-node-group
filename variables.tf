variable "name" {}

variable "cluster_name" {}

variable "ssh_key" {}

variable "subnet_ids" {
  type = set(string)
}

variable "instance_type" {}

variable "desired_size" {}

variable "max_size" {
  default = null
}

variable "min_size" {
  default = null
}

variable "user_data" {
  default = null
}

variable "node_pool_class" {
  default = "general"
}

variable "labels" {
  type    = map(string)
  default = null
}

variable "taints" {
  type = map(object({
    effect = string
    key    = string
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_security_group_ids" {
  type    = set(string)
  default = []
}