output "id" {
  value = aws_s3_bucket.this.id
}

output "arn" {
  value = aws_s3_bucket.this.arn
}

output "objects" {
  value = sort([for o in aws_s3_object.this : "s3://${o.bucket}/${o.key}"])
}
