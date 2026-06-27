# CDC Pro for Redis docs

Public product and customer onboarding site for the commercial CDC Pro for
Redis bundle.

Published site:

https://kanutocd.github.io/cdc-redis-pro-docs/

## Clone

```sh
git clone https://github.com/kanutocd/cdc-redis-pro-docs.git
cd cdc-redis-pro-docs
```

## What this repo contains

- [`docs/index.html`](docs/index.html): public product landing page, licensing overview, and benchmark evidence.
- [`docs/reports/`](docs/reports/index.html): benchmark, soak, chaos, and verification reports.
- [`docs/reports/analytics/`](docs/reports/analytics/index.html): generated benchmark analytics dashboard.
- [`examples/cdc-redis-pro-pipeline/`](examples/cdc-redis-pro-pipeline/README.md): standalone Ruby sample showing Redis source modes, worker-local upstream pooling, and downstream orchestration.
- [`examples/cdc-redis-pro-rails-dashboard/`](examples/cdc-redis-pro-rails-dashboard/README.md): Rails sample showing the public source modes, bounded demo runs, and local API docs for the licensed bundle.

## Product summary

CDC Pro for Redis is a paid Ruby CDC bundle for Redis-heavy systems. It pairs
fast Redis source drivers with downstream orchestration primitives for
concurrent processing, worker-local resource pools, and benchmark-backed
runtime tuning.

The bundle covers:

- Redis Streams with consumer groups, checkpointing, pending-entry recovery,
  duplicate suppression, and dead-letter streams.
- Redis Pub/Sub, pattern Pub/Sub, and Redis Cluster sharded Pub/Sub with
  explicit at-most-once loss-window reporting.
- Redis keyspace notifications with startup validation and optional
  best-effort value enrichment.
- Sentinel failover, Redis Cluster routing, same-slot Cluster Streams,
  multi-primary Cluster keyspace subscriptions, TLS, and ACL authentication.
- `cdc-orchestrator-pro` nested runtime support: Ractors outside, fibers
  inside, worker-local resources through `LocalResourcePool`, and failure
  policy handling.
- Private GitHub Packages distribution with signed offline license tokens.

## Preview locally

Open the public site:

```text
docs/index.html
```

Serve it however you prefer, or open the file directly in a browser.

## Deploy

The included GitHub Actions workflow deploys `docs/` to GitHub Pages.
