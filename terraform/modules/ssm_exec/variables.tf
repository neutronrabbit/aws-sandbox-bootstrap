variable "instance_id" {
  description = "ID of the EC2 instance to run the command on"
  type        = string
}

variable "commands" {
  description = "List of shell commands to run on the instance"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

