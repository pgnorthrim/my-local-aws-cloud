# My Local AWS Cloud

A local, disposable emulation of the AWS services used in data-lake and ETL
designs, so architecture ideas can be built and tested on a laptop or VM
before anything is deployed to a real account.

**Status:** early scaffolding. Nothing below under "Planned stack" is built yet.

## Goals

- Prototype data-lake and streaming designs locally, at zero cloud cost.
- Keep every component reproducible from one command (`docker compose up`).
- Mirror production service boundaries so designs carry over to real AWS.
- Stay safe to destroy and rebuild at any time; no real data lives here.

## Planned stack

| Concern              | Local component                        | AWS service it stands in for |
|----------------------|----------------------------------------|------------------------------|
| Object storage       | LocalStack S3 or MinIO                 | S3                           |
| Streaming            | LocalStack Kinesis (and Kafka, to compare) | Kinesis / MSK            |
| Table format         | Apache Iceberg (medallion: bronze/silver/gold) | Iceberg on S3        |
| Query / transform    | DuckDB, Polars, PyIceberg              | Athena / Glue                |
| Catalog              | Iceberg REST or SQL catalog            | Glue Data Catalog            |

## Prerequisites

- Docker (or Podman) with the compose plugin
- Python 3.11+ with a virtualenv
- AWS CLI v2 (pointed at the local endpoint, not a real account)

## Layout (planned)

```
my-local-aws-cloud/
  docker-compose.yml   # the local services
  scripts/             # bootstrap: buckets, streams, catalog
  examples/            # small end-to-end pipelines
  docs/                # design notes
```

## Usage

Not available yet. Once the compose file lands:

```bash
docker compose up -d
./scripts/bootstrap.sh
```

## Safety rules

- Use dummy credentials and a local endpoint only.
- Never put real or client data in this repo or its volumes.
- Treat all local state as throwaway.

## License

None chosen yet; the repo is private.
