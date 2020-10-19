require "fileutils"
require "stringio"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rbnotes"

require "minitest/autorun"

module RbnotesTestUtils
  CONF_RO = {
    :repository_type => :file_system,
    :repository_name => "test_repo",
    :repository_base => File.expand_path("fixtures", __dir__),
  }

  CONF_RW = {
    :repository_type => :file_system,
    :repository_name => "test_repo",
    :repository_base => File.expand_path("sandbox", __dir__),
  }

  def repo_path(conf)
    [:repository_base, :repository_name].map{|k| conf[k]}.join("/")
  end

  def load_cmd(name)
    Rbnotes::Commands.load(name.to_s)
  end

  def execute(name, args, conf)
    cmd = load_cmd(name)
    result, _ = capture_io { cmd.execute(args, conf) }
    result
  end

  def timestamp_to_path(timestamp, repo)
    return nil unless timestamp.size == 14
    dirname = File.expand_path(File.join([0..3, 4..5].map{|r| timestamp[r]}), repo)
    File.join(dirname, "#{timestamp}.md")
  end
end

FileUtils.mkdir_p(File.expand_path("sandbox", __dir__))
