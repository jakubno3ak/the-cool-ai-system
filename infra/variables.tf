variable "public_subnet_cidr" {
    type        = string
    description = "Public Subnets CIDRs"
    default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
    type        = string
    description = "Private Subnets CIDRs"
    default     = "10.0.4.0/24"
}

variable "availability_zone" {
    type = string
    description = "Availability Zones"
    default = "eu-west-1a"
}