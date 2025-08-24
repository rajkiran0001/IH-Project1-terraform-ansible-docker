terraform {
  backend "s3" {
    bucket         = "project-1-prod-terraform-state-bucket"   # same as above
    key            = "env/prod/terraform.tfstate"       # path within the bucket
    region         = "ap-southeast-1"                  # your region
    encrypt        = true
    dynamodb_table = "ih-project1-prod-terraform-lock-table"            # name of DynamoDB table
  }
}