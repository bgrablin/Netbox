variable "region" { default = "us-west-2" }
variable "default_AZ" { default = "us-west-2a" }
variable cidr_block_internet { default = "0.0.0.0/0" }
variable "ssh_key_public" {
  default     = "~/.ssh/Netbox/id_rsa.pub"
  description = "Path to the SSH public key for accessing cloud instances. Used for creating AWS keypair."
}
variable "ssh_key_private" {
  default     = "~/.ssh/Netbox/id_rsa"
  description = "Path to the SSH private key for accessing cloud instances."
}
variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "172.31.0.0/16"
}
variable "allocation_id" {
    default = "eipalloc-0cc00b5a9859e7c3b"
}
variable "hosted_zone" {
    default = "grayanalytics.io."
}