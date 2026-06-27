namespace :docs do
  desc "Generate local YARD API docs for the installed private gems"
  task generate: :environment do
    require "bundler"
    require "fileutils"

    gem_paths = %w[cdc-redis-pro cdc-orchestrator-pro].map do |name|
      Bundler.load.specs.find { |spec| spec.name == name }&.full_gem_path or
        raise "Missing installed gem: #{name}"
    end

    output_dir = Rails.root.join("doc")
    public_dir = Rails.root.join("public/docs/api")
    FileUtils.rm_rf(output_dir)
    FileUtils.rm_rf(public_dir)

    cmd = ["bundle", "exec", "yard", "doc", *gem_paths, "-o", output_dir.to_s]
    puts cmd.join(" ")
    abort("docs:generate failed") unless system(*cmd)

    FileUtils.mkdir_p(public_dir)
    FileUtils.cp_r("#{output_dir}/.", public_dir.to_s)
  end
end
