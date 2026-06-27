class ModesController < ApplicationController
  before_action :load_scenario

  def streams = render_mode
  def pubsub = render_mode
  def sharded_pubsub = render_mode
  def keyspace = render_mode
  def orchestrator = render_mode

  def run_streams = enqueue_run
  def run_pubsub = enqueue_run
  def run_sharded_pubsub = enqueue_run
  def run_keyspace = enqueue_run
  def run_orchestrator = enqueue_run

  private

  def load_scenario
    @scenario = CdcRedisProSamples::Catalog.fetch(action_name.delete_prefix("run_"))
    @latest_run = DemoRun.latest_for(@scenario.key)
  end

  def render_mode
    render :show
  end

  def enqueue_run
    run = DemoRun.create!(
      mode: @scenario.key,
      title: @scenario.label,
      status: :queued,
      summary: @scenario.summary,
      config_path: @scenario.config_path,
      command: @scenario.command_line
    )
    RunDemoJob.perform_later(run.id)
    redirect_to public_send("#{action_name.delete_prefix("run_")}_path"), notice: "#{@scenario.label} demo queued."
  end
end
