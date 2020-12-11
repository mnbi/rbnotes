require "fileutils"
require "stringio"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rbnotes"

require "minitest/autorun"

module RbnotesTestUtils
  CONF_RO = {
    :config_home => File.expand_path("fixtures", __dir__),
    :repository_type => :file_system,
    :repository_name => "test_repo",
    :repository_base => File.expand_path("fixtures", __dir__),
  }

  CONF_RW = {
    :config_home => File.expand_path("sandbox", __dir__),
    :repository_type => :file_system,
    :repository_name => "test_repo",
    :repository_base => File.expand_path("sandbox", __dir__),
  }

  def repo_path(conf)
    File.join([:repository_base, :repository_name].map{|k| conf[k]})
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
    return nil unless timestamp.size == 14 || timestamp.size == 18
    dirname = File.expand_path(File.join([0..3, 4..5].map{|r| timestamp[r]}), repo)
    File.join(dirname, "#{timestamp}.md")
  end

  def search_in_paths(cmd_name)
    ENV["PATH"].split(":").each { |d|
      abs = File.expand_path(cmd_name, d)
      return abs if FileTest.exist?(abs)
    }
    nil
  end

  def prepare_note(timestamp, text, repo_path)
    note_path = timestamp_to_path(timestamp, repo_path)
    FileUtils.mkdir_p(File.dirname(note_path))
    File.open(note_path, "w") { |f| f.puts text.join("\n") }
    note_path
  end

  def prepare_note_from_file(timestamp, file_path, repo_path)
    text = File.readlines(file_path, :chomp => true)
    prepare_note(timestamp, text, repo_path)
  end
end

FileUtils.mkdir_p(File.expand_path("sandbox", __dir__))
