variable "region" {
  type = string
  default = "ap-southeast-1"
}

variable "account_id" {
  type = string
  default = "" #your aws account id
}

#parameters for networking module
variable "availability_zones" {
  type = list(string)
  nullable = false
}
variable "cidr_block" {
  type = string
  nullable = false
}
variable "public_subnet_ips" {
  type = list(string)
  nullable = false
  
}
variable "private_subnet_ips" {
  type = list(string)
  nullable = false
}


