module "s3_vote_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  create_bucket            = var.lambdas.vote_handler.vote_bucket_create
  bucket                   = var.lambdas.vote_handler.vote_bucket
  acl                      = "private"
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  versioning = {
    enabled = true
  }
}
