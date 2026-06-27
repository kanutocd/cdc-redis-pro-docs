# CDC Pro for Redis docs

Public product and customer onboarding site for the commercial CDC Pro for
Redis bundle:

- `cdc-redis-pro`
- `cdc-orchestrator-pro`

Published site:

https://kanutocd.github.io/cdc-redis-pro-docs/

## Product Positioning

CDC Pro for Redis is a paid Ruby CDC bundle for Redis-heavy systems. It pairs
fast Redis source drivers with downstream orchestration primitives for
concurrent processing, worker-local resource pools, and benchmark-backed
runtime tuning.

## What The Bundle Covers

- Redis Streams with consumer groups, checkpointing, pending-entry recovery,
  duplicate suppression, and dead-letter streams.
- Redis Pub/Sub, pattern Pub/Sub, and Redis Cluster sharded Pub/Sub with
  explicit at-most-once loss-window reporting.
- Redis keyspace notifications with startup configuration validation and
  optional best-effort value enrichment.
- Sentinel failover, Redis Cluster routing, same-slot Cluster Streams,
  multi-primary Cluster keyspace subscriptions, TLS, and ACL authentication.
- `cdc-orchestrator-pro` nested runtime support: Ractors outside, fibers
  inside, worker-local resources through `LocalResourcePool`, and failure
  policy handling.
- Private GitHub Packages distribution with signed offline license tokens.

## Site Structure

- `docs/index.html`: product and license landing page.
- `docs/reports/`: benchmark, soak, chaos, and verification reports.
- `docs/reports/analytics/`: generated benchmark analytics dashboard.

The implementation repos and gem packages remain private. This repo is for
public product discovery, customer evaluation, and link sharing.

## Deploy

The included GitHub Actions workflow deploys `docs/` to GitHub Pages.

Manual setup:

1. Enable GitHub Pages for this repository.
2. Select GitHub Actions as the Pages source.
3. Push changes to `main`.
