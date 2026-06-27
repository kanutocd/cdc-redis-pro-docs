require "open3"

module CdcRedisProSamples
  RunResult = Data.define(:stdout, :stderr, :exit_status, :elapsed_seconds) do
    def success?
      exit_status == 0
    end
  end

  class CommandRunner
    def self.call(command:, env: {}, chdir: Rails.root)
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      stdout, stderr, status = Open3.capture3(env, *command, chdir: chdir.to_s)
      elapsed_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
      RunResult.new(stdout:, stderr:, exit_status: status.exitstatus, elapsed_seconds:)
    end
  end
end
