variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_id" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "os_domain" {
  type = string
}

variable "auth_domain" {
  type = string
}

variable "email" {
  type = string
}

#Defaults

variable "all_ip" {
  default = "0.0.0.0/0"
}
