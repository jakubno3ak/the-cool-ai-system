variable "ecr_name" {
    description = "The name of the ECR repo"
    type        = string
}

variable "image_tag_mutability" {
    description = "The mutability of the images tags"
    type        = string
    default     = "IMMUTABLE"
}

variable "encrypt_type" {
    description = "The type of encryption"
    type        = string
    default     = "KMS"
}

variable "tags" {
    description = "Tags"
    type        = map(string)
    default     = {}
}

variable "public_subnet_cidrs" {
    type        = list(string)
    description = "Public Subnets CIDRs"
    default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
    type        = list(string)
    description = "Private Subnets CIDRs"
    default     = ["10.0.4.0/24"]
}

variable "availability_zones" {
    type = list(string)
    description = "Availability Zones"
    default = ["eu-west-1a"]
}