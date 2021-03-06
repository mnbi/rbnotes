require "test_helper"

class RbnotesCommandsImportTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb

  def setup
    @conf_rw = CONF_RW.dup
    @conf_rw[:repository_name] = "test_repo_for_import"
  end

  def teardown
    path = repo_path(@conf_rw)
    FileUtils.rm_r(path) if FileTest.exist?(path)
  end

  def test_that_it_can_import_an_existing_file
    src_file = File.expand_path("fixtures/text/apple.md", __dir__)

    expected = expected_path(src_file)
    refute FileTest.exist?(expected)

    # execute rbnotes command
    execute(:import, [src_file], @conf_rw)

    assert FileTest.exist?(expected)
    assert FileUtils.identical?(src_file, expected)
  end

  def test_that_it_can_import_the_given_file_even_if_its_timestamp_is_already_attached_to_the_different_note
    src_file = File.expand_path("fixtures/text/cpu.md", __dir__)
    other_file = File.expand_path("fixtures/text/programming_languages.md", __dir__)

    # prepare a test situation
    target_path = expected_path(src_file)
    FileUtils.mkdir_p(File.dirname(target_path))
    FileUtils.cp(other_file, target_path)

    expected = expected_path(src_file).sub(/\.md/, "_001.md")
    refute FileTest.exist?(expected)

    # execute rbnotes command
    execute(:import, [src_file], @conf_rw)

    assert FileTest.exist?(expected)
    assert FileUtils.identical?(src_file, expected)
  end

  def test_it_fails_to_import_empty_text
    src_file = File.expand_path(File.join("fixtures", "text", "empty.md"), __dir__)
    result = execute(:import, [src_file], @conf_rw)
    assert result.include?("empty")
  end

  def test_it_uses_mtime_when_specified
    sandbox_dir = File.expand_path("test_for_import", File.expand_path("sandbox", __dir__))
    # prepare a file to import
    text = ["This file is intended to be used for import."]
    FileUtils.mkdir_p(sandbox_dir)
    filepath = File.expand_path("importfile.md", sandbox_dir)
    File.open(filepath, "w") { |f| f.puts text }

    # The following test is valid only if the system has `birthtime`.
    st = File::Stat.new(filepath)
    if st.respond_to?(:birthtime)
      btime = File::Stat.new(filepath).birthtime
      sleep(1)                    # wait 1 second to change `mtime`
      mtime = Time.now
      assert false, "increase sleep seconds, then retry" if equal_time?(btime, mtime)
      FileUtils.touch(filepath, :mtime => mtime)

      # import the file
      result = execute(:import, ["-m", filepath], @conf_rw)
      check_imported_file(result, mtime)

      # prepare to import
      old_mtime = File::Stat.new(filepath).mtime
      sleep(1)
      mtime = Time.now
      assert false, "increase sleep seconds, then retry" if equal_time?(old_mtime, mtime)
      FileUtils.touch(filepath, :mtime => mtime)

      # import the file
      result = execute(:import, ["--use-mtime", filepath], @conf_rw)
      check_imported_file(result, mtime)
    end
  end

  private
  def expected_path(org_file)
    st = File::Stat.new(org_file)
    btime = st.respond_to?(:birthtime) ? st.birthtime : st.mtime

    timestamp_to_path(btime.strftime("%Y%m%d%H%M%S"), repo_path(@conf_rw))
  end

  def equal_time?(t0, t1)
    a0, a1 = [t0, t1].map { |t|
      [:year, :month, :day, :hour, :min, :sec].map { |s| t.send(s) }
    }
    a0 == a1
  end

  def check_imported_file(result, mtime)
    /timestamp\s+\[([0-9]+)\]/.match(result) { |md|
      timestamp_str = md[1]
      assert_includes timestamp_str, mtime.strftime("%Y%m%d%H%M%S")

      notepath = timestamp_to_path(timestamp_str, repo_path(@conf_rw))
      refute notepath.nil?
    }
  end

end
