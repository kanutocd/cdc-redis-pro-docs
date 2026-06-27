# CDC Pro for Redis Rails dashboard

Rails sample for the commercial CDC Pro for Redis bundle.

What it shows:

- `cdc-redis-pro` source modes for Streams, Pub/Sub, sharded Pub/Sub, and keyspace notifications
- `cdc-orchestrator-pro` downstream orchestration through a bounded demo run
- the orchestrator demo uses `REDIS_URL` for the Redis sink, defaulting to `redis://127.0.0.1:6379/0`
- local API docs generation for the installed private gems
- license and package access requirements for customers

## Setup

```sh
bundle config set --local https://rubygems.pkg.github.com/kanutocd USER:TOKEN
```

or configure credentials system wide:

```sh
bundle config https://rubygems.pkg.github.com/kanutocd USER:TOKEN
export CDC_REDIS_PRO_LICENSE_KEY="..."
export CDC_REDIS_PRO_LICENSE_PUBLIC_KEY="..."
export CDC_ORCHESTRATOR_PRO_LICENSE_KEY="..."
export CDC_ORCHESTRATOR_PRO_LICENSE_PUBLIC_KEY="..."
bundle install
bin/rails db:create db:migrate
bin/rails server
```

## Demo pages

- `/` dashboard
- `/streams`
- `/pubsub`
- `/sharded-pubsub`
- `/keyspace`
- `/orchestrator`
- `/docs`
- `/license`

## Local API docs

```sh
bundle exec rake docs:generate
```

Open `doc/index.html`.
