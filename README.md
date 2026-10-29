# My Local AWS Cloud

A local, disposable stand-in for the AWS services used in data-lake and ETL designs, plus
Terraform building blocks, so any project can create buckets, streams and other services on
a laptop or VM before anything is deployed to a real account.

**Status:** Moto (replaces LocalStack) + Iceberg REST catalog running; `s3-bucket` Terraform
module, a project template and a `core` stack built and tested. Other service modules are added
when a project needs them.

## Stack

| Concern           | Local component                          | AWS service it stands in for |
|-------------------|------------------------------------------|------------------------------|
| AWS APIs          | Moto 5.2.4 (Apache 2.0, free)            | S3, Kinesis, SQS, SNS, DynamoDB, SSM, Secrets Manager, ... |
| Table format      | Apache Iceberg (bronze/silver/gold)       | Iceberg on S3                |
| Catalog           | Iceberg REST fixture (port 8181)         | Glue Data Catalog            |
| Infrastructure    | Terraform, `hashicorp/aws ~> 6.0`        | Same code as real AWS        |
| Query / transform | DuckDB, Polars, PyIceberg (planned)      | Athena / Glue                |

Moto replaced LocalStack on 2026-10-29: LocalStack's current images need a paid account token;
Moto is free and maintained. Moto answers on the same port LocalStack used (4566).

## Layout

```
docker-compose.yml       Moto (localhost:4566) + Iceberg REST (localhost:8181)
modules/s3-bucket/       bucket + encryption + public-access block + optional versioning,
                         optionally loaded from a local folder
templates/project/       starter Terraform stack pointed at Moto
stacks/core/             warehouse/bronze/silver/gold buckets + Kinesis stream "events"
scripts/bootstrap.sh     build stacks/core
scripts/new-stack.sh     new stack from the template (here or in another project)
scripts/tf-apply.sh      init + apply a stack (handles a Moto tagging quirk)
```

## Usage

```bash
docker compose up -d          # start Moto + Iceberg REST
./scripts/bootstrap.sh        # build the core stack (rerun after restarting Moto)
docker compose down           # stop; Moto is in-memory, so everything is wiped
```

Use the AWS CLI against it:

```bash
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566
unset AWS_PROFILE
aws s3 ls
```

## New stack for any project

```bash
./scripts/new-stack.sh my-project ~/some-project/infra   # or just <name> for stacks/<name>/
./scripts/tf-apply.sh ~/some-project/infra
```

The new stack has a provider pointed at Moto, standard tags, and an example bucket:

```hcl
module "raw" {
  source        = "../../my-local-aws-cloud/modules/s3-bucket"   # written for you, relative
  name          = "my-project-raw"
  force_destroy = true                                           # local only
  data_dir      = "${path.module}/data/raw"                      # optional: folder -> objects
}
```

- `data_dir`: `<data_dir>/<prefix>/<file>` becomes `s3://<name>/<prefix>/<file>`. Changed files are
  re-uploaded; removed files are deleted on the next apply. Dotfiles are skipped.
- Other services: add plain resources (e.g. `aws_sqs_queue`, `aws_ssm_parameter`); the provider
  already routes them to Moto.
- Moving to real AWS: replace the provider block with a real profile and region (no endpoints,
  no dummy keys). Modules and resources stay the same.
- A project's data and any client material stay in that project, never in this repo.

## Notes

- Moto keeps state in memory. After a restart, rerun `tf-apply.sh` / `bootstrap.sh`: Terraform sees
  the resources are gone and recreates them.
- Moto ignores tags sent while creating a bucket or stream; `tf-apply.sh` runs a second apply when
  the first leaves anything unset.
- Ports bind to 127.0.0.1 only. `iceberg-rest-fixture` is not version-pinned yet.

## Safety rules

- Dummy credentials and a local endpoint only. Real AWS rejects the dummy keys.
- No real or client data in this repo. Treat all local state as throwaway.

## License

None chosen yet; the repo is private.
