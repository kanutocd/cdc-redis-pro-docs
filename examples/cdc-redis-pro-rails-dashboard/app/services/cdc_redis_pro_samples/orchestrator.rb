module CdcRedisProSamples
  class Orchestrator < BaseScenario
    def self.key = "orchestrator"
    def self.label = "cdc-orchestrator-pro"
    def self.summary = "Nested runtime and downstream processing through the commercial orchestrator."
    def self.config_path = "config/sources/streams.yml"
    def self.route_name = :orchestrator
    def self.command
      redis_url = ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")
      %W[bundle exec cdc-redis-pro pipe --config config/sources/streams.yml --batch-size 50 --ractors 4 --redis-connections 4 --fibers 10 --preserve-order false --limit 20 --timeout 20 --metrics prometheus --redis-url #{redis_url}]
    end
  end
end
