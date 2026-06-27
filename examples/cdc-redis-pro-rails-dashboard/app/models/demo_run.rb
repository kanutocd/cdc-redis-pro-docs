class DemoRun < ApplicationRecord
  enum :status, {
    queued: "queued",
    running: "running",
    succeeded: "succeeded",
    failed: "failed"
  }, prefix: true

  validates :mode, :title, :status, presence: true

  def self.latest_for(mode)
    where(mode:).order(created_at: :desc).first
  end

  def self.latest_by_mode
    order(created_at: :desc).group_by(&:mode)
  end

  def command_line
    Array(command).join(" ")
  end

  def output_tail(lines = 20)
    [stdout, stderr].compact.flat_map { |text| text.to_s.lines }.last(lines).join
  end
end
