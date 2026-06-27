module CdcRedisProSamples
  class PubSub < BaseScenario
    def self.key = "pubsub"
    def self.label = "Redis Pub/Sub"
    def self.summary = "Low-latency ephemeral delivery with explicit loss-window semantics."
    def self.config_path = "config/sources/pubsub.yml"
    def self.route_name = :pubsub
    def self.command = %w[bundle exec cdc-redis-pro run --config config/sources/pubsub.yml --limit 8 --timeout 15 --metrics prometheus]
  end
end
