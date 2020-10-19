require "tmpdir"
require "test_helper"

class RbnotesUtilsTest < Minitest::Test
  def setup
    @clean_files = []
  end

  def teardown
    FileUtils.rm_f(@clean_files)
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
    tmpfile = File.expand_path("rbnotes_utils_test_run_with_tmpfile.txt", Dir.tmpdir)
    program = File.expand_path("fake_editor", __dir__)
    rc = system(program, tmpfile)

    @clean_files << tmpfile
    assert rc && FileTest.exist?(tmpfile)
  end
end
