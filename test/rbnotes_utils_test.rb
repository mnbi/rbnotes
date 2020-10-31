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

    result = Rbnotes::Utils.find_editor(abs_of_editor)
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
    result = Rbnotes::Utils.find_editor("/usr/local/bin/hoge_editor")
    unless result.nil?
      assert [ENV["EDITOR"], "nano", "vi"].include?(File.basename(result))
    end
  end

  # find_program(names)
  def test_find_program_can_find_sh_in_paths
    refute Rbnotes::Utils.find_program(["sh"]).nil?
  end

  def test_find_program_can_find_bin_sh_in_paths
    abs = "/bin/sh"
    if FileTest.exist?(abs)
      refute Rbnotes::Utils.find_program([abs]).nil?
    end
  end

  def test_find_program_can_pick_a_executable_in_args
    args = ["foo", "hoge", "sh", "zzz", "ls", "/bin/cp", "/etc/hosts"]
    expected = "/bin/sh"
    if FileTest.exist?(expected)
      assert_equal expected, Rbnotes::Utils.find_program(args)
    end
  end

  # run_with_tmpfile(prog, filename)
  def test_run_with_tmpfile_can_handle_a_tmpefile
    tmpname = "rbnotes_utils_test_run_with_tmpfile"
    program = File.expand_path("fake_editor", __dir__)

    tmpfile = Rbnotes::Utils.run_with_tmpfile(program, tmpname)

    @clean_files << tmpfile
    assert tmpfile && FileTest.exist?(tmpfile)
  end

  # read_arg(io)
  def test_read_arg_returns_nil_when_reads_nil_from_io
    nilio = StringIO.new
    arg = Rbnotes::Utils.read_arg(nilio)
    assert arg.nil?
  end
end
