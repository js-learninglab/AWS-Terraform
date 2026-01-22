### creating this tf file to setup ecr repo###

### creating ecr repo ###
resource "aws_ecr_repository" "a_ecr_repo" {
  name = "jslearninglab-ecr-repo" #not using naming convention so that workspace will use this but images are tagged as :Dev or :prod based on workspace

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-ecr-repo" })
}


## putting a policy for retention / lifecycle policy

resource "aws_ecr_lifecycle_policy" "a_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.a_ecr_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      },
      action = {
        type = "expire"
      }
      }
    ]
  })

}
