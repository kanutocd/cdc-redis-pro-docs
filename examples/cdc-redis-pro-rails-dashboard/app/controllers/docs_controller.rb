require "open3"

class DocsController < ApplicationController
  DOCS_INDEX = Rails.root.join("public/docs/api/index.html")

  def index
    docs_state
  end

  def generate
    stdout, stderr, status = Open3.capture3("bundle", "exec", "rake", "docs:generate", chdir: Rails.root.to_s)

    if status.success?
      redirect_to docs_path, notice: "Local API docs generated."
    else
      redirect_to docs_path, alert: [stdout, stderr].reject(&:blank?).join("\n").presence || "Docs generation failed."
    end
  end

  private

  def docs_state
    @local_docs_path = "public/docs/api/index.html"
    @local_docs_url = "/docs/api/index.html"
    @docs_ready = docs_ready?
  end

  def docs_ready?
    DOCS_INDEX.exist?
  end
end
