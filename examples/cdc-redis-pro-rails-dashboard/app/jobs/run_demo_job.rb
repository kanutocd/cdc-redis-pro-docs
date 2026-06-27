class RunDemoJob < ApplicationJob
  queue_as :default

  def perform(demo_run_id)
    demo_run = DemoRun.find(demo_run_id)
    scenario = CdcRedisProSamples::Catalog.fetch(demo_run.mode)

    demo_run.update!(status: :running, started_at: Time.current)
    result = scenario.run
    demo_run.update!(
      status: result.success? ? :succeeded : :failed,
      finished_at: Time.current,
      exit_status: result.exit_status,
      elapsed_seconds: result.elapsed_seconds,
      stdout: result.stdout,
      stderr: result.stderr
    )
  rescue StandardError => e
    demo_run&.update!(
      status: :failed,
      finished_at: Time.current,
      stderr: [demo_run&.stderr, "#{e.class}: #{e.message}"].compact.join("\n"),
      summary: [demo_run&.summary, "job failed"].compact.join(" - ")
    )
  end
end
