class DemoRunsController < ApplicationController
  def show
    @run = DemoRun.find(params[:id])
  end
end
