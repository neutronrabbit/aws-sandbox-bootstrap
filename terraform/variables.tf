variable "region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  default = "10.100.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "subnet_cidrs" {
  description = "Map of subnet groups with CIDRs per AZ"
  type = object({
    infra_eks = list(string)
    app_eks   = list(string)
    egress    = list(string)
    dmz       = list(string)
  })
  default = {
    infra_eks = ["10.100.0.0/20",   "10.100.16.0/20"]
    app_eks   = ["10.100.32.0/20",  "10.100.48.0/20"]
    egress    = ["10.100.64.0/20",  "10.100.80.0/20"]
    dmz       = ["10.100.96.0/20",  "10.100.112.0/20"]
  }
}


