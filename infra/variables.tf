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