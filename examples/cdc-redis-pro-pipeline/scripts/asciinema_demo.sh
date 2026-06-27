#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
Asciinema demo flow

Record:
  asciinema rec cdc-redis-pro-pipeline.cast

Pane 1: upstream producer with worker-local pool
  cd /home/ken/Documents/mi-proyekto/open-source/cdc-redis-pro-docs/examples/cdc-redis-pro-pipeline
  docker compose up -d
  TRACE_DEMO=1 UPSTREAM_MODE=inception UPSTREAM_POOL_SIZE=4 UPSTREAM_RACTORS=4 UPSTREAM_FIBERS=10 UPSTREAM_TIMEOUT=30 COUNT=200 bundle exec ruby bin/produce_stream.rb

Pane 2: downstream batch processing with process_many
  cd /home/ken/Documents/mi-proyekto/open-source/cdc-redis-pro-docs/examples/cdc-redis-pro-pipeline
  # Run this after Pane 1 has started Redis with docker compose up -d.
  TRACE_DEMO=1 COUNT=200 bundle exec ruby bin/sample_jsonl.rb | \
    TRACE_DEMO=1 BATCH_SIZE=50 RACTORS=4 FIBER_CONCURRENCY=50 DOWNSTREAM_CONNECTIONS=6 \
    bundle exec ruby bin/process_many_jsonl.rb

Pane 3: show OS-level concurrency
  watch -n 0.5 'ps -L -p $(pgrep -n ruby) -o pid,tid,psr,pcpu,comm --sort=tid | head -20'

Optional:
  top -H -p $(pgrep -n ruby)

Notes:
  - TRACE_DEMO=1 prints worker identity lines to stderr.
  - UPSTREAM_MODE=inception switches Pane 1 from a single worker-local pool to the nested inception pool path.
  - Increase UPSTREAM_TIMEOUT if you want the inception demo to keep waiting on a much larger COUNT.
  - Both producer and downstream scripts print an end-of-run elapsed-time and throughput summary.
  - process_many_jsonl.rb emits ractor_id in each JSON result.
  - ps/top show threads, while the trace lines show the runtime worker IDs.
  - If you want a no-write trace demo without Redis, add FAILURE_MODE=record to Pane 2.
EOF
