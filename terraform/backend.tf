terraform {
  backend "s3" {
    bucket         = "project-1-terraform-state-bucket"   # same as above
    key            = "env/dev/terraform.tfstate"       # path within the bucket
    region         = "ap-southeast-1"                  # your region
    encrypt        = true
    dynamodb_table = "ih-project1-terraform-lock-table"            # name of DynamoDB table
  }
}
