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
      timestamp_str = File.basename(file, ".*")
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

  # accept multiple args (issue #79)
  def test_that_it_accepts_multiple_timestamps
    args = ["20201012005000", "20200912005001", "20191012005002"]
    cmd = load_cmd(:show)
    cmd.execute(args, @conf_ro)

    pager_output = File.readlines(@pager_out, chomp: true)

    args.each { |stamp_str|
      file = timestamp_to_path(stamp_str, repo_path(@conf_ro))

      File.readlines(file, chomp: true).each { |line|
        assert_includes pager_output, line
      }
    }
  end

  def test_that_it_can_read_multiple_timestamps_from_stdin
    args = ["20201012005002", "20200912005000", "20191012005001"]

    cmd = load_cmd(:show)
    $stdin = StringIO.new(args.join("\n"))
    cmd.execute([], @conf_ro)
    $stdin = STDOUT

    pager_output = File.readlines(@pager_out, chomp: true)

    args.each { |stamp_str|
      file = timestamp_to_path(stamp_str, repo_path(@conf_ro))

      File.readlines(file, chomp: true).each { |line|
        assert_includes pager_output, line
      }
    }
  end

end
