# frozen_string_literal: true

require "json"
require "cdc/redis/pro"
require_relative "../lib/demo_trace"

redis_url = ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")
batch_size = Integer(ENV.fetch("BATCH_SIZE", "100"), 10)
value_field = ENV.fetch("VALUE_FIELD", nil)
failure_mode = ENV.fetch("FAILURE_MODE", "raise").to_sym

sink = CDC::Redis::Pro::Orchestrator.redis_sink(
  connection: { url: redis_url },
  redis_connections: Integer(ENV.fetch("DOWNSTREAM_CONNECTIONS", "5"), 10),
  key_prefix: ENV.fetch("KEY_PREFIX", "orders_projection"),
  id_field: ENV.fetch("ID_FIELD", "stream_id"),
  value_field: value_field && !value_field.empty? ? value_field : nil,
  failure_mode: failure_mode
)

runtime = CDC::Redis::Pro::Orchestrator.runtime(
  processor: sink,
  ractors: Integer(ENV.fetch("RACTORS", "3"), 10),
  fiber_concurrency: Integer(ENV.fetch("FIBER_CONCURRENCY", "50"), 10),
  timeout: Float(ENV.fetch("TIMEOUT", "30.0")),
  preserve_order: ENV.fetch("PRESERVE_ORDER", "true") == "true",
  partition_strategy: ENV.fetch("PARTITION_STRATEGY", "round_robin").to_sym
)


buffer = []
total_events = 0
total_batches = 0
started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
DemoTrace.trace(
  "downstream runtime",
  "ractors=#{ENV.fetch("RACTORS", "3")} fibers=#{ENV.fetch("FIBER_CONCURRENCY", "50")} batch_size=#{batch_size}"
)

def build_change_event(event_hash)
  kwargs = symbolize_keys(event_hash)
  kwargs[:operation] = kwargs[:operation].to_sym if kwargs[:operation]

  CDC::Core::ChangeEvent.new(
    operation: kwargs.fetch(:operation),
    schema: kwargs.fetch(:schema),
    table: kwargs.fetch(:table),
    old_values: kwargs[:old_values],
    new_values: kwargs[:new_values],
    primary_key: kwargs[:primary_key],
    transaction_id: kwargs[:transaction_id],
    commit_lsn: kwargs[:commit_lsn],
    sequence_number: kwargs[:sequence_number],
    occurred_at: kwargs[:occurred_at],
    metadata: kwargs[:metadata] || {}
  )
end

def symbolize_keys(value)
  case value
  when Hash
    value.each_with_object({}) do |(key, nested), acc|
      acc[key.to_sym] = symbolize_keys(nested)
    end
  when Array
    value.map { |entry| symbolize_keys(entry) }
  else
    value
  end
end

def emit_results(results)
  Array(results).each do |result|
    value = result.respond_to?(:to_h) ? result.to_h : result
    puts JSON.generate(result: value)
  end
end

def verify_redis!(redis_url)
  client = RedisClient.config(url: redis_url).new_client
  client.call("PING")
rescue StandardError => e
  warn "Redis preflight failed for #{redis_url}: #{e.class}: #{e.message}"
  warn "Start Redis with `docker compose up -d`, or set FAILURE_MODE=record for a no-write trace demo."
  exit 1
ensure
  client&.close
end

verify_redis!(redis_url) if failure_mode == :raise

ARGF.each_line do |line|
  next if line.strip.empty?

  payload = JSON.parse(line)
  buffer << build_change_event(payload.fetch("change_event", payload))

  next unless buffer.length >= batch_size

  DemoTrace.trace("downstream batch", "items=#{buffer.length}")
  total_batches += 1
  total_events += buffer.length
  emit_results(runtime.process_many(buffer))
  buffer.clear
end

DemoTrace.trace("downstream batch", "items=#{buffer.length}") unless buffer.empty?
if buffer.any?
  total_batches += 1
  total_events += buffer.length
  emit_results(runtime.process_many(buffer))
end

elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
throughput = elapsed.positive? ? (total_events / elapsed) : 0.0
warn format(
  "[demo] downstream summary batches=%<batches>d events=%<events>d elapsed=%<elapsed>.2fs throughput=%<throughput>.1f events/s",
  batches: total_batches,
  events: total_events,
  elapsed: elapsed,
  throughput: throughput
)
