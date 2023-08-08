variable "folder_id" {
  type = string
}

variable "network_name" {
  type = string
}

variable "network_description" {
  type    = string
  default = ""
}

variable "public_subnets" {
  type = any
}

variable "private_subnets" {
  type = any
}

variable "labels" {
  type    = map(string)
  default = {}
}
