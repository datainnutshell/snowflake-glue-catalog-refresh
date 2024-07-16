resource "random_integer" "bucket_name_int" {
  min = 1
  max = 50000
}

resource "aws_s3_bucket" "datalake" {
  bucket = "glue-catalog-bucket-test-${random_integer.bucket_name_int.result}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "exampdatalakele" {
  bucket = aws_s3_bucket.datalake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}