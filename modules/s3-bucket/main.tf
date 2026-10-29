# One S3 bucket with safe defaults: encrypted, public access blocked, optional versioning,
# optionally loaded from a local folder. Works the same against Moto and real AWS; only the
# provider configuration differs.
locals {
  files = var.data_dir == null ? toset([]) : toset([
    for f in fileset(var.data_dir, "**") : f
    if !startswith(basename(f), ".")
  ])
}

resource "aws_s3_bucket" "this" {
  bucket        = var.name
  force_destroy = var.force_destroy
  tags          = merge({ Name = var.name }, var.tags)
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "this" {
  for_each = local.files
  bucket   = aws_s3_bucket.this.id
  key      = each.key
  source   = "${var.data_dir}/${each.key}"
  etag     = filemd5("${var.data_dir}/${each.key}")
}
