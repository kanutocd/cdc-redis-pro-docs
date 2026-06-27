module CdcRedisProSamples
  Scenario = Data.define(:key, :label, :summary, :config_path, :route_name, :command_line)

  module Catalog
    module_function

    def all
      [
        CdcRedisProSamples::Streams,
        CdcRedisProSamples::PubSub,
        CdcRedisProSamples::ShardedPubSub,
        CdcRedisProSamples::Keyspace,
        CdcRedisProSamples::Orchestrator
      ].map(&:scenario)
    end

    def fetch(key)
      {
        "streams" => CdcRedisProSamples::Streams,
        "pubsub" => CdcRedisProSamples::PubSub,
        "sharded_pubsub" => CdcRedisProSamples::ShardedPubSub,
        "keyspace" => CdcRedisProSamples::Keyspace,
        "orchestrator" => CdcRedisProSamples::Orchestrator
      }.fetch(key.to_s)
    end
  end
end
