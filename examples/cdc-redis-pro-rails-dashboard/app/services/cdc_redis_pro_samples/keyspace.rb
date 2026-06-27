module CdcRedisProSamples
  class Keyspace < BaseScenario
    def self.key = "keyspace"
    def self.label = "Redis keyspace notifications"
    def self.summary = "Mutation notification tracking with optional enrichment."
    def self.config_path = "config/sources/keyspace.yml"
    def self.route_name = :keyspace
    def self.command = %w[bundle exec cdc-redis-pro run --config config/sources/keyspace.yml --limit 8 --timeout 15 --metrics prometheus]
  end
end
