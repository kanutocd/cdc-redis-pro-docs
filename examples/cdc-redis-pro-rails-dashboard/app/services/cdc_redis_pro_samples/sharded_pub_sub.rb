module CdcRedisProSamples
  class ShardedPubSub < BaseScenario
    def self.key = "sharded_pubsub"
    def self.label = "Redis Cluster sharded Pub/Sub"
    def self.summary = "Cluster-aware sharded Pub/Sub routing across hash slots."
    def self.config_path = "config/sources/sharded_pubsub.yml"
    def self.route_name = :sharded_pubsub
    def self.command = %w[bundle exec cdc-redis-pro run --config config/sources/sharded_pubsub.yml --limit 8 --timeout 15 --metrics prometheus]
  end
end
