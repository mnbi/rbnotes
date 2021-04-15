require "rbconfig"
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
    # Following test depends on its running platform, such as OS or
    # PATH setting.
    if RbConfig::CONFIG["host_os"].include?("darwin")
      args = ["foo", "hoge", "sh", "zzz", "ls", "/bin/cp", "/etc/hosts"]
      expected = "/bin/sh"
      if FileTest.exist?(expected)
        assert_equal expected, Rbnotes.utils.find_program(args)
      end
    else
      assert true
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

  # read_timestamp(args)
  def test_read_timestamp_returns_a_timetamp
    timestamp0 = Textrepo::Timestamp.now
    args = [timestamp0.to_s]
    $stdin = StringIO.new(args.join("\n"))

    stamp = Rbnotes.utils.read_timestamp([])
    assert_equal timestamp0, stamp
  end

  # read_multiple_timestamps(args)
  def test_read_multiple_timestamps_returns_an_array_of_timestamps
    timestamp0 = Textrepo::Timestamp.now
    stamp_args = [timestamp0, timestamp0.succ]
    args = stamp_args.map(&:to_s)
    $stdin = StringIO.new(args.join("\n"))

    stamps = Rbnotes.utils.read_multiple_timestamps([])

    assert_equal stamp_args, stamps.sort
  end

  # for issue #98
  def test_read_multiple_timestamps_removes_redundant_args
    s0 = "2021-03-30_12:53:00"
    s1 = "2020-01-01_11:22:33"
    s2 = "2021-03-01_22:33:44"
    args = [s0, s1, s0, s1, s2, s2].map{ |s| s.tr("-_:", "") }
    stamps = Rbnotes.utils.read_multiple_timestamps(args)

    assert_equal args.uniq.size, stamps.size

    # check the order
    assert_equal s0.tr("-_:", ""), stamps[0].to_s
    assert_equal s1.tr("-_:", ""), stamps[1].to_s
    assert_equal s2.tr("-_:", ""), stamps[2].to_s
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
    days = Rbnotes.utils.timestamp_patterns_in_week(a_day.to_s)
    refute days.nil?
    assert_equal 7, days.size

    days.sort!

    assert_equal days_of_week, days
  end
end
