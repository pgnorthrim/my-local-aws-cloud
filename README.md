# My Local AWS Cloud

A local, disposable emulation of the AWS services used in data-lake and ETL
designs, so architecture ideas can be built and tested on a laptop or VM
before anything is deployed to a real account.

**Status:** early scaffolding. S3 and Kinesis (LocalStack) and an Iceberg REST catalog run locally; Iceberg table examples and query tooling are not built yet.

## Goals

- Prototype data-lake and streaming designs locally, at zero cloud cost.
- Keep every component reproducible from one command (`docker compose up`).
- Mirror production service boundaries so designs carry over to real AWS.
- Stay safe to destroy and rebuild at any time; no real data lives here.

## Planned stack

| Concern              | Local component                        | AWS service it stands in for |
|----------------------|----------------------------------------|------------------------------|
| Object storage       | LocalStack S3 (4.4, pinned)                 | S3                           |
| Streaming            | LocalStack Kinesis (Kafka later, to compare) | Kinesis / MSK            |
| Table format         | Apache Iceberg (medallion: bronze/silver/gold) | Iceberg on S3        |
| Query / transform    | DuckDB, Polars, PyIceberg              | Athena / Glue                |
| Catalog              | Iceberg REST fixture (port 8181)       | Glue Data Catalog            |

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

```bash
docker compose up -d
./scripts/bootstrap.sh     # creates buckets warehouse/bronze/silver/gold and stream "events"
docker compose down -v     # wipe everything
```

Endpoints (localhost only): S3/Kinesis at `http://localhost:4566`, Iceberg REST at
`http://localhost:8181`. Use dummy credentials (`test` / `test`) and region `us-east-1`.

## Notes

- LocalStack is pinned to 4.4. Recent `latest` images refuse to start without a
  LocalStack auth token. Revisit (or switch to MinIO) before upgrading.
- Both published ports bind to 127.0.0.1 only.

## Safety rules

- Use dummy credentials and a local endpoint only.
- Never put real or client data in this repo or its volumes.
- Treat all local state as throwaway.

## License

None chosen yet; the repo is private.
