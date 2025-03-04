variable "instance_type" {
  type        = string
  description = "Type of EC2 instance to launch. Example: t2.micro"
  default = "t2.micro"
}
variable "region" {
  type = string
  default = "ap-southeast-1"
}
variable security_groups {
  type = list(string)
  default = ["default"]
}
variable "subnet_id1" {
  type = string
}
variable "subnet_id2" {
  type = string
}
variable "amis" {
  type = map(any)
  default = {
    "ap-southeast-1" : "ami-047126e50991d067b" #Ubuntu 
  }
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = "waf_project_key_pair"
}