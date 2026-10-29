# Core local stack: the medallion buckets (Iceberg warehouse + bronze/silver/gold) and one
# Kinesis stream. Built by scripts/bootstrap.sh.
module "bucket" {
  for_each = toset(["warehouse", "bronze", "silver", "gold"])
  source   = "../../modules/s3-bucket"

  name          = each.key
  force_destroy = true # local only
}

resource "aws_kinesis_stream" "events" {
  name             = "events"
  shard_count      = 1
  retention_period = 24
}

output "buckets" {
  value = sort([for b in module.bucket : b.id])
}

output "streams" {
  value = [aws_kinesis_stream.events.name]
}
