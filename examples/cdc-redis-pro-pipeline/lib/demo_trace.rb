# frozen_string_literal: true

module DemoTrace
  module_function

  def enabled?
    value = ENV.fetch("TRACE_DEMO", nil)
    value && !%w[0 false no off].include?(value.downcase)
  end

  def worker_identity
    parts = [
      "pid=#{Process.pid}",
      "tid=#{Thread.current.object_id}",
      "fiber=#{Fiber.current.object_id}"
    ]
    parts << "ractor=#{Ractor.current.object_id}" if defined?(Ractor)
    parts.join(" ")
  end

  def trace(label, details = nil)
    return unless enabled?

    message = +"[demo] #{label} #{worker_identity}"
    message << " #{details}" if details && !details.to_s.empty?
    $stderr.puts(message)
  end
end
