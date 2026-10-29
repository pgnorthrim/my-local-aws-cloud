# Example: one bucket, optionally loaded from ./data/example-bucket/.
# Add more buckets with more module blocks, or other services as plain resources.
module "example_bucket" {
  source = "__MODULES__/s3-bucket"

  name          = "__STACK__-example"
  force_destroy = true # local only
  # data_dir    = "${path.module}/data/example-bucket"
}

output "example_bucket" {
  value = module.example_bucket.id
}
