module CdcRedisProSamples
  class BaseScenario
    class << self
      def command_line
        command.join(" ")
      end

      def scenario
        Scenario.new(
          key:,
          label:,
          summary:,
          config_path:,
          route_name:,
          command_line:
        )
      end

      def run
        CommandRunner.call(command:, env:)
      end

      def env
        {
          "TRACE_DEMO" => ENV.fetch("TRACE_DEMO", "1")
        }
      end
    end
  end
end
