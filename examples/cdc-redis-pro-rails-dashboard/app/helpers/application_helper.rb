module ApplicationHelper
  def status_class(status)
    case status.to_s
    when "succeeded" then "status status-success"
    when "running" then "status status-running"
    when "failed" then "status status-failed"
    else "status status-queued"
    end
  end

  def format_seconds(value)
    return "n/a" if value.blank?

    format("%.2fs", value)
  end

  def external_link_label(label)
    tag.span(label) + tag.span(" ↗", aria_hidden: true, class: "external-link-indicator")
  end
end
