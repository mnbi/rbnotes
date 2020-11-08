require "test_helper"

class RbnotesCommandsExportTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb

  def setup
    @conf = CONF_RO.dup
    @export_dir = File.expand_path("test_for_export",
                                   File.expand_path("sandbox", __dir__))
    FileUtils.mkdir_p(@export_dir)
  end

  def test_it_can_write_out_file_with_given_note
    timestamp_str = "20201012005000"

    result = nil
    Dir.chdir(@export_dir) {
      result = execute(:export, [timestamp_str], @conf)
    }
    assert_success_to_export(result, timestamp_str)
  end

  def test_it_can_write_out_file_with_given_note_with_suffix
    timestamp_str = "20201012005000_089"

    result = nil
    Dir.chdir(@export_dir) {
      result = execute(:export, [timestamp_str], @conf)
    }
    assert_success_to_export(result, timestamp_str)
  end

  def test_it_can_export_as_the_specified_file
    timestamp_str = "20201012005001"

    dst_path = File.expand_path("test_export.md", @export_dir)
    result = nil
    result = execute(:export, [timestamp_str, dst_path], @conf)

    assert_success_to_export(result, timestamp_str, dst_path)
  end

  def test_it_read_arg_from_stdio
    timestamp_str = "20201012005002"

    cmd = load_cmd(:export)
    result = nil
    Dir.chdir(@export_dir) {
      $stdin = StringIO.new(timestamp_str)
      result, _ = capture_io { cmd.execute([], @conf) }
      $stdin = STDIN
    }

    assert_success_to_export(result, timestamp_str)
  end

  def test_it_ignores_extra_args
    timestamp_str = "20201012005003"
    dst_path = File.expand_path("test_export_with_extra_args.md", @export_dir)

    result = nil
    result = execute(:export, [timestamp_str, dst_path, "foo", "bar"], @conf)

    assert_success_to_export(result, timestamp_str, dst_path)
  end

  private
  def assert_success_to_export(result, timestamp_str, dst_path = nil)
    note_path = timestamp_to_path(timestamp_str, repo_path(@conf))
    stamp, path = extract_stamp_and_path(result)

    if dst_path.nil?
      dst_path = File.expand_path(path, @export_dir)
    else
      assert_includes dst_path, path
    end

    assert_equal timestamp_str, stamp
    assert_path_exists dst_path
    assert FileUtils.identical?(note_path, dst_path)
  end

  def extract_stamp_and_path(output)
    md = /\[([0-9]{14}(?:_[0-9]{3})?)\].+\[(.+\.md)\]/.match(output)
    md[1..2]
  end
end
