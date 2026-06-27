# cdc-redis-pro pipeline sample

Standalone Ruby sample for the commercial CDC Pro for Redis bundle:

- `cdc-redis-pro 0.9.0`
- `cdc-orchestrator-pro 0.9.0`

This sample is public, but it only runs for licensed customers with GitHub
Packages access and a signed offline license token.

## What it shows

- An upstream producer that uses `CDC::Orchestrator::Pro::LocalResourcePool`
  for worker-local Redis clients.
- The four Redis event system modes exposed by `cdc-redis-pro`:
  - Redis Streams
  - Redis Pub/Sub
  - Redis Cluster sharded Pub/Sub
  - Redis keyspace notifications
- A downstream batch processor that calls
  `CDC::Redis::Pro::Orchestrator.runtime(...).process_many(...)`.
- Local API docs generation from the installed private gems.

This is intentionally a plain Ruby sample. Rails is not required.

## Prerequisites

- Ruby 4.0+
- Docker with Compose
- GitHub username with package access
- GitHub PAT classic with `read:packages`
- CDC Pro license token and public verification key

## Setup

Start Redis:

```sh
docker compose up -d
```

Configure GitHub Packages access:

```sh
bundle config https://rubygems.pkg.github.com/kanutocd GITHUB_USER:GITHUB_PAT
```

Export license environment variables:

```sh
export CDC_REDIS_PRO_LICENSE_KEY="cdc-license-v1..."
export CDC_REDIS_PRO_LICENSE_PUBLIC_KEY="-----BEGIN PUBLIC KEY-----..."

export CDC_ORCHESTRATOR_PRO_LICENSE_KEY="$CDC_REDIS_PRO_LICENSE_KEY"
export CDC_ORCHESTRATOR_PRO_LICENSE_PUBLIC_KEY="$CDC_REDIS_PRO_LICENSE_PUBLIC_KEY"
```

Install dependencies:

```sh
bundle install
```

## Upstream producer

`bin/produce_stream.rb` has two upstream modes.

`UPSTREAM_MODE=single` uses one worker-local `LocalResourcePool`. That shows
the basic local client checkout pattern without outer fan-out.

`UPSTREAM_MODE=inception` uses `NestedRuntime` with outer Ractors and an inner
worker-local pool. That is the inception-pool path: each Ractor owns its own
local Redis client pool, and `process_with_resource` runs against the resource
checked out from that pool.

```sh
bundle exec ruby bin/produce_stream.rb
```

To show the full inception-pool path, switch to the nested runtime mode:

```sh
TRACE_DEMO=1 UPSTREAM_MODE=inception UPSTREAM_POOL_SIZE=4 UPSTREAM_RACTORS=4 UPSTREAM_FIBERS=10 UPSTREAM_TIMEOUT=30 \
  bundle exec ruby bin/produce_stream.rb
```

By default this writes 10 events to `cdc:orders`. At the end it prints a small
elapsed-time and throughput summary.

Override values:

```sh
COUNT=100 STREAM=cdc:orders REDIS_URL=redis://127.0.0.1:6379/0 \
  bundle exec ruby bin/produce_stream.rb
```

## Downstream batch processing

`bin/process_many_jsonl.rb` reads JSONL `change_event` rows from stdin and
forwards them through `CDC::Redis::Pro::Orchestrator.runtime(...).process_many`.

```sh
bundle exec ruby bin/sample_jsonl.rb | \
  bundle exec ruby bin/process_many_jsonl.rb
```

The downstream processor uses the same worker-local pool shape that was
benchmarked in the commercial runtime.
It also prints an elapsed-time and throughput summary when the stream ends.

For a recording-friendly walkthrough, use `scripts/asciinema_demo.sh` as the
command sequence and set `TRACE_DEMO=1` on the producer and downstream
commands. Run `docker compose up -d` before the downstream command so the
Redis sink can write successfully. For a trace-only recording without Redis,
set `FAILURE_MODE=record`.

## Recordings

Hosted asciinema recordings:

- Streams recording:
  [https://asciinema.org/a/ZgYkH5QwZLDFJ6YL](https://asciinema.org/a/ZgYkH5QwZLDFJ6YL)
  [![asciicast](https://asciinema.org/a/ZgYkH5QwZLDFJ6YL.svg)](https://asciinema.org/a/ZgYkH5QwZLDFJ6YL)
- Pub/Sub recording:
  [https://asciinema.org/a/nnV4iiRX6Pw0YEag](https://asciinema.org/a/nnV4iiRX6Pw0YEag)
  [![asciicast](https://asciinema.org/a/nnV4iiRX6Pw0YEag.svg)](https://asciinema.org/a/nnV4iiRX6Pw0YEag)
- Sharded Pub/Sub recording:
  [https://asciinema.org/a/5hyyHBrML12Bu6z4](https://asciinema.org/a/5hyyHBrML12Bu6z4)
  [![asciicast](https://asciinema.org/a/5hyyHBrML12Bu6z4.svg)](https://asciinema.org/a/5hyyHBrML12Bu6z4)
- Keyspace recording:
  [https://asciinema.org/a/H6mhFGoUTTiNmj6x](https://asciinema.org/a/H6mhFGoUTTiNmj6x)
  [![asciicast](https://asciinema.org/a/H6mhFGoUTTiNmj6x.svg)](https://asciinema.org/a/H6mhFGoUTTiNmj6x)

## Redis source modes

Use these config files with `cdc-redis-pro run` to inspect the source families
that the bundle supports publicly:

| Mode | Config | What it demonstrates |
| --- | --- | --- |
| Streams | `config/sources/streams.yml` | Recoverable stream replay and consumer-group semantics |
| Pub/Sub | `config/sources/pubsub.yml` | Low-latency ephemeral delivery |
| Sharded Pub/Sub | `config/sources/sharded_pubsub.yml` | Cluster-aware sharded delivery |
| Keyspace | `config/sources/keyspace.yml` | Notification-driven key changes |

Example:

```sh
bundle exec cdc-redis-pro run --config config/sources/streams.yml
bundle exec cdc-redis-pro run --config config/sources/pubsub.yml
bundle exec cdc-redis-pro run --config config/sources/sharded_pubsub.yml
bundle exec cdc-redis-pro run --config config/sources/keyspace.yml
```

The sharded Pub/Sub config is a reference for Redis Cluster. It needs a cluster
endpoint list, not the standalone Redis container from the default compose
file. Cluster keyspace notifications use the same keyspace model with the
dedicated `cluster_keyspace` source kind if you want to extend this sample for
a multi-primary Redis cluster.

## Generate local API docs

```sh
bundle exec rake docs:generate
```

Then open:

```text
doc/index.html
```

This generates the API documentation for the installed `cdc-redis-pro` and
`cdc-orchestrator-pro` gems.

This command only works after:

- `bundle install` has resolved the private gems from GitHub Packages
- Bundler is configured with a valid `read:packages` token
- the signed license token and public key environment variables are set

If the gems are not installed yet, `docs:generate` will fail because the local
API docs are built from the installed gem source paths.

For a browser-based sample that exposes the same public source modes and
orchestrator launch buttons, see
`examples/cdc-redis-pro-rails-dashboard/`.

## Stop Redis

```sh
docker compose down -v
```

## Notes

- Redis Streams are recoverable compared with Pub/Sub and keyspace
  notifications.
- The direct `pipe` command requires both `cdc-redis-pro` and
  `cdc-orchestrator-pro` license entitlements.
- This sample does not commit `Gemfile.lock` so customers can resolve against
  their package access and platform.
