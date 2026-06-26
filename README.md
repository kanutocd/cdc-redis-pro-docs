# cdc-redis-pro-docs

Public documentation mirror for `cdc-redis-pro`, a commercial Redis source
driver package for Ruby and `cdc-core`.

Published site:

https://kanutocd.github.io/cdc-redis-pro-docs/

## What cdc-redis-pro Covers

- Redis Streams with consumer groups, checkpointing, pending-entry recovery,
  duplicate suppression, and dead-letter streams.
- Redis Pub/Sub, pattern Pub/Sub, and Redis Cluster sharded Pub/Sub with
  explicit at-most-once loss-window reporting.
- Redis keyspace notifications with startup configuration validation and
  optional best-effort value enrichment.
- Sentinel failover, Redis Cluster routing, same-slot Cluster Streams,
  multi-primary Cluster keyspace subscriptions, TLS, and ACL authentication.

## Repository Model

The production implementation stays private. This public repository exists for
documentation, discovery, search indexing, and link sharing.

The published GitHub Pages content lives in `docs/`.

## Deploy

The included GitHub Actions workflow deploys `docs/` to GitHub Pages.

Manual setup:

1. Enable GitHub Pages for this repository.
2. Select GitHub Actions as the Pages source.
3. Push changes to `main`.
