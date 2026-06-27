class DashboardController < ApplicationController
  def index
    @scenarios = CdcRedisProSamples::Catalog.all
    @latest_runs = DemoRun.latest_by_mode
  end
end
