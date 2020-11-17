require "tmpdir"
require "test_helper"

class RbnotesUtilsTest < Minitest::Test
  include RbnotesTestUtils

  def setup
    @clean_files = []
  end

  def teardown
    FileUtils.rm_f(@clean_files)
  end

  # find_editor
  def test_find_editor_can_find_some_external_editor
    abs_of_editor = "/usr/local/bin/emacsclient"
    abs_of_nano = search_in_paths("nano")
    abs_of_vi = search_in_paths("vi")

    result = Rbnotes.utils.find_editor(abs_of_editor)
    if FileTest.exist?(abs_of_editor)
      assert_equal abs_of_editor, result
    elsif FileTest.exist?(abs_of_nano)
      assert_equal abs_of_nano, result
    elsif FileTest.exist?(abs_of_vi)
      assert_equal abs_of_vi, result
    else
      refute result
    end
  end

  def test_find_editor_finds_some_external_editor_in_other_case
    result = Rbnotes.utils.find_editor("/usr/local/bin/hoge_editor")
    unless result.nil?
      assert [ENV["EDITOR"], "nano", "vi"].include?(File.basename(result))
    end
  end

  # find_program(names)
  def test_find_program_can_find_sh_in_paths
    refute Rbnotes.utils.find_program(["sh"]).nil?
  end

  def test_find_program_can_find_bin_sh_in_paths
    abs = "/bin/sh"
    if FileTest.exist?(abs)
      refute Rbnotes.utils.find_program([abs]).nil?
    end
  end

  def test_find_program_can_pick_a_executable_in_args
    args = ["foo", "hoge", "sh", "zzz", "ls", "/bin/cp", "/etc/hosts"]
    expected = "/bin/sh"
    if FileTest.exist?(expected)
      assert_equal expected, Rbnotes.utils.find_program(args)
    end
  end

  # run_with_tmpfile(prog, filename)
  def test_run_with_tmpfile_can_handle_a_tmpefile
    tmpname = "rbnotes_utils_test_run_with_tmpfile"
    program = File.expand_path("fake_editor", __dir__)

    tmpfile = Rbnotes.utils.run_with_tmpfile(program, tmpname)

    @clean_files << tmpfile
    assert tmpfile && FileTest.exist?(tmpfile)
  end

  # read_arg(io)
  def test_read_arg_returns_nil_when_reads_nil_from_io
    nilio = StringIO.new
    arg = Rbnotes.utils.read_arg(nilio)
    assert arg.nil?
  end

  # timestamps_in_week(timestamp)
  def test_timestamp_patterns_in_week_enumerates_timestamps
    a_day = Textrepo::Timestamp.new(Time.new(2020, 11, 17, 0, 0, 0))
    days_of_week = [
      "2020-11-16",             # Mon
      "2020-11-17",             # Tue
      "2020-11-18",             # Wed
      "2020-11-19",             # Thu
      "2020-11-20",             # Fri
      "2020-11-21",             # Sat
      "2020-11-22",             # Sun
    ].map { |d| d.tr("-", "") }
    days = Rbnotes.utils.timestamp_patterns_in_week(a_day)
    refute days.nil?
    assert_equal 7, days.size

    days.sort!

    assert_equal days_of_week, days
  end
end
