module CdcRedisProSamples
  class Streams < BaseScenario
    def self.key = "streams"
    def self.label = "Redis Streams"
    def self.summary = "Recoverable stream replay with consumer-group semantics."
    def self.config_path = "config/sources/streams.yml"
    def self.route_name = :streams
    def self.command = %w[bundle exec cdc-redis-pro run --config config/sources/streams.yml --limit 8 --timeout 15 --metrics prometheus]
  end
end
