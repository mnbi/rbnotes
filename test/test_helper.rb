require "fileutils"
require "stringio"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rbnotes"

require "minitest/autorun"

module RbnotesTestUtils
  def load_cmd(name)
    Rbnotes::Commands.load(name.to_s)
  end

  def execute(name, args, conf)
    cmd = load_cmd(name)
    result = ""
    StringIO.open(result, "w") { |out|
      $stdout = out
      cmd.execute(args, conf)
      $stdout = STDOUT
    }
    result
  end
end

FileUtils.mkdir_p(File.expand_path("sandbox", __dir__))
