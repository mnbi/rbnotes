require "test_helper"

class RbnotesCommandsShowTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def setup
    @pager_out = File.expand_path("sandbox/show_pager.out", __dir__)
    @conf_ro = CONF_RO.dup
    @conf_ro[:pager] = "cat > #{@pager_out}"
  end

  def test_that_it_can_show_the_specified_note
    files = [
      "20201012005000.md",
      "20201012005000_089.md",
    ]
    cmd = load_cmd(:show)

    files.each { |file|
      timestamp_str = file[0..-4]
      file = timestamp_to_path(timestamp_str, repo_path(@conf_ro))

      cmd.execute([timestamp_str], @conf_ro)

      assert FileUtils.identical?(file, @pager_out)
    }
  end

  def test_that_it_reads_arg_from_stdin_when_no_args
    timestamp_str = "20201012005001"
    file = timestamp_to_path(timestamp_str, repo_path(@conf_ro))

    cmd = load_cmd(:show)
    $stdin = StringIO.new(timestamp_str)
    cmd.execute([], @conf_ro)
    $stdin = STDIN

    assert FileUtils.identical?(file, @pager_out)
  end
end
