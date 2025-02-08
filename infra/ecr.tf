resource "aws_ecr_repository" "ecr" {
  
  name = "the-cool-ai-system-ecr"
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "KMS"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name= "TheCoolAISystemEcr"
    }
}