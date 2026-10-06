#!/usr/bin/env bash
# Create the local buckets and streams. Safe to re-run.
set -euo pipefail

export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 AWS_DEFAULT_OUTPUT=json
EP=http://localhost:4566
aws="aws --endpoint-url $EP"

for b in warehouse bronze silver gold; do
  $aws s3api head-bucket --bucket "$b" >/dev/null 2>&1 || $aws s3api create-bucket --bucket "$b" >/dev/null
  echo "bucket: $b"
done

$aws kinesis describe-stream-summary --stream-name events >/dev/null 2>&1 \
  || $aws kinesis create-stream --stream-name events --shard-count 1
echo "stream: events"
