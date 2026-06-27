# frozen_string_literal: true

require "json"
require "time"

count = Integer(ENV.fetch("COUNT", "5"), 10)

count.times do |index|
  order_id = "jsonl-order-#{index + 1}"
  event = {
    operation: "insert",
    schema: "sample",
    table: "orders",
    primary_key: { id: order_id },
    new_values: {
      id: order_id,
      customer_id: "customer-#{(index % 3) + 1}",
      total_cents: 2_000 + (index * 250)
    },
    old_values: nil,
    transaction_id: "sample-jsonl",
    commit_lsn: nil,
    sequence_number: index + 1,
    occurred_at: Time.now.utc.iso8601,
    metadata: { source: "sample_jsonl" }
  }

  puts JSON.generate(change_event: event)
end
