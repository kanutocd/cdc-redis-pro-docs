# frozen_string_literal: true

require "json"
require "redis-client"
require "securerandom"
require "cdc/orchestrator/pro"
require_relative "../lib/demo_trace"

redis_url = ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")
stream = ENV.fetch("STREAM", "cdc:orders")
count = Integer(ENV.fetch("COUNT", "10"), 10)
pool_size = Integer(ENV.fetch("UPSTREAM_POOL_SIZE", "2"), 10)
pool_timeout = Float(ENV.fetch("UPSTREAM_POOL_TIMEOUT", "5.0"))
runtime_timeout = Float(ENV.fetch("UPSTREAM_TIMEOUT", "30.0"))
upstream_mode = ENV.fetch("UPSTREAM_MODE", "single").to_sym
preserve_order = ENV.fetch("PRESERVE_ORDER", "false") == "true"
partition_strategy = ENV.fetch("PARTITION_STRATEGY", "round_robin").to_sym

DemoTrace.trace("upstream mode", "mode=#{upstream_mode}, preserve_order=#{preserve_order}")

def monotonic_time
  Process.clock_gettime(Process::CLOCK_MONOTONIC)
end

def print_summary(label, count, started_at)
  elapsed = monotonic_time - started_at
  throughput = elapsed.positive? ? (count / elapsed) : 0.0
  warn format("[demo] %<label>s summary events=%<count>d elapsed=%<elapsed>.2fs throughput=%<throughput>.1f events/s",
              label: label, count: count, elapsed: elapsed, throughput: throughput)
end

ConnectionFactory = Data.define(:url) do
  def call
    RedisClient.config(url:).new_client
  end
end

class InceptionProducer
  def initialize(stream:)
    @stream = String(stream).freeze
    freeze
  end

  def process_with_resource(item, client)
    order_id = item.fetch(:id)
    DemoTrace.trace("process_with_resource", "stream=#{@stream} event=#{order_id}")

    stream_id = client.call(
      "XADD",
      @stream,
      "*",
      "event",
      "order.created",
      "id",
      order_id,
      "payload",
      JSON.generate(item)
    )

    Ractor.make_shareable(
      {
        event_id: order_id,
        stream: @stream,
        stream_id: stream_id,
        ractor_id: Ractor.current.object_id
      }
    )
  end
end

case upstream_mode
when :single
  emitted = 0
  connection_factory = Ractor.make_shareable(ConnectionFactory.new(redis_url))
  pool = CDC::Orchestrator::Pro::LocalResourcePool.new(
    size: pool_size,
    timeout: pool_timeout,
    factory: connection_factory
  )

  pool.prewarm!
  DemoTrace.trace("upstream pool", "size=#{pool_size}")

  begin
    started_at = monotonic_time
    count.times do |index|
      order_id = "order-#{index + 1}"
      payload = {
        id: order_id,
        customer_id: "customer-#{(index % 3) + 1}",
        total_cents: 1_000 + (index * 125),
        trace_id: SecureRandom.hex(8)
      }

      pool.with do |client|
        DemoTrace.trace("upstream checkout", "stream=#{stream} event=#{order_id}")
        id = client.call(
          "XADD",
          stream,
          "*",
          "event",
          "order.created",
          "id",
          order_id,
          "payload",
          JSON.generate(payload)
        )

        puts "#{stream} #{id} #{order_id}"
        emitted += 1
      end
    end
  ensure
    DemoTrace.trace("upstream close")
    pool&.close_current_worker!
    print_summary("upstream", emitted, started_at)
  end
when :inception  
  events = count.times.map do |index|
    order_id = "order-#{index + 1}"
    {
      id: order_id,
      customer_id: "customer-#{(index % 3) + 1}",
      total_cents: 1_000 + (index * 125),
      trace_id: SecureRandom.hex(8)
    }
  end

  started_at = monotonic_time
  processor = InceptionProducer.new(stream:)
  connection_factory = Ractor.make_shareable(ConnectionFactory.new(redis_url))
  runtime = CDC::Orchestrator::Pro::NestedRuntime.new(
    processor:,
    connection_factory:,
    parallel_size: Integer(ENV.fetch("UPSTREAM_RACTORS", "4"), 10),
    connections_per_worker: pool_size,
    inner_concurrency: Integer(ENV.fetch("UPSTREAM_FIBERS", "10"), 10),
    timeout: runtime_timeout,
    preserve_order:,
    partition_strategy: :round_robin
  )

  DemoTrace.trace(
    "upstream inception",
    "ractors=#{ENV.fetch("UPSTREAM_RACTORS", "4")} fibers=#{ENV.fetch("UPSTREAM_FIBERS", "10")} \
     size=#{pool_size} preserve_order=#{preserve_order} timeout=#{runtime_timeout}"
  )
  results = runtime.process_many(events)
  results.each do |result|
    puts "#{result.fetch(:stream)} #{result.fetch(:stream_id)} #{result.fetch(:event_id)}"
  end
  print_summary("upstream", results.length, started_at)
else
  abort "unknown UPSTREAM_MODE=#{upstream_mode}. Use single or inception."
end
