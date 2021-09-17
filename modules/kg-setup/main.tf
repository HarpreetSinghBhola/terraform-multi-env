resource "aws_s3_bucket" "terraform_state" {
  count                   = length(var.s3_bucket_backend_name)
  bucket = element(var.s3_bucket_backend_name,   count.index)
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = var.enable_versioning
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.encryption_sse_algorithm
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = local.tags
}

