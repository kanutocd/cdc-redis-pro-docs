# cdc-redis-pro pipe CLI verification

This note records customer-visible CLI behavior for the direct Redis source to
`cdc-orchestrator-pro` pipeline. It is not a throughput benchmark and should
not be compared with the CSV benchmark matrix.

Verified behavior in the private `cdc-redis-pro` quality gate:

- `pipe` runs a configured Redis source directly through `cdc-orchestrator-pro`.
- Redis Streams sources use a batch-aware path when `--batch-size` is greater than `1`.
- `XACK` and checkpoint advancement remain downstream-success gated.
- Prometheus output includes source-runner metrics and orchestrator counters:
  - `cdc_redis_pro_orchestrator_events`
  - `cdc_redis_pro_orchestrator_batches`
  - `cdc_redis_pro_orchestrator_failures`
  - `cdc_redis_pro_orchestrator_batch_latency_ms_total`

Example:

```bash
bundle exec cdc-redis-pro pipe \
  --config config/redis-source.yml \
  --redis-url "$REDIS_URL" \
  --batch-size 100 \
  --ractors 3 \
  --redis-connections 5 \
  --fibers 50 \
  --metrics prometheus
```

The published benchmark dashboard remains the source for throughput, latency,
CPU, RSS, soak, and chaos artifacts.
