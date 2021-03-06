require "test_helper"

class RbnotesCommandsAddTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def setup
    @conf_rw = CONF_RW.dup
    @conf_rw[:repository_name] = "test_repo_for_add"
    @conf_rw[:editor] = File.expand_path("fake_editor", __dir__)
  end

  def teardown
    remove_template_file
  end

  def test_that_it_can_create_a_new_note
    assert_success_to_add_with_timestamp(nil, true)
  end

  def test_that_it_fails_to_crete_with_empty_content
    conf = @conf_rw.dup
    conf[:editor] = File.expand_path("fake_editor_empty_content", __dir__)

    result = execute(:add, [], conf)
    assert result.include?("empty text")
  end

  ##
  # for `-t STAMP_PATTERN`

  def test_it_accepts_stamp_pattern_full_qualified
    assert_success_to_add_with_timestamp("20201104170400", false)
  end

  def test_it_accepts_stamp_pattern_full_qualified_with_suffix
    assert_success_to_add_with_timestamp("20201104170400_012", false)
  end

  def test_it_accepts_stamp_pattern_omit_sec_part
    assert_success_to_add_with_timestamp("202011041705", false)
  end

  def test_it_accepts_stamp_pattern_omit_year_and_sec_part
    assert_success_to_add_with_timestamp("11041706", false)
  end

  def test_it_fails_with_nil_as_pattern
    assert_raises(ArgumentError) {
      execute(:add, ["-t"], @conf_rw)
    }
  end

  def test_it_fails_with_invalid_stamp_pattern
    assert_raises(Textrepo::InvalidTimestampStringError) {
      execute(:add, ["-t", "ruby_birthday"], @conf_rw)
    }
  end

  # [issue #45]
  def test_it_ignores_extra_arguments_in_wrong_syntax
    result = execute(:add, ["apple", "imac", "2020"], @conf_rw)
    assert_success_to_add(result)
  end

  # [issue #48]
  def test_it_does_nothing_when_no_modification_in_the_editor
    conf = @conf_rw.dup
    conf[:editor] = File.expand_path("fake_editor_do_nothing", __dir__)
    result = execute(:add, [], conf)
    refute_empty result
    assert_includes result, "Cancel"
  end

  def test_it_take_template_file_content
    prepare_template_file

    conf = @conf_rw.dup
    conf[:editor] = File.expand_path("fake_editor_do_nothing", __dir__)
    result = execute(:add, [], conf)

    stamp_str = /[A-z ]+\[([0-9_]+)\]/.match(result).to_a[1]
    refute stamp_str.nil?
    note_path = timestamp_to_path(stamp_str, repo_path(conf))

    content = File.readlines(note_path, chomp: true)
    assert_equal TEMPLATE, content

    FileUtils.rm_f(note_path)
  end

  private
  def assert_success_to_add_with_timestamp(pattern = nil, cleanup = true)
    args = pattern.nil? ? [] : ["-t", pattern]
    result = execute(:add, args, @conf_rw)
    assert_success_to_add(result, cleanup)
  end

  def assert_success_to_add(result, cleanup = true)
    stamp_str = /[A-z ]+\[([0-9_]+)\]/.match(result).to_a[1]
    refute stamp_str.nil?

    note_path = timestamp_to_path(stamp_str, repo_path(@conf_rw))
    assert_path_exists note_path

    FileUtils.rm_f(note_path) if cleanup
  end

  TEMPLATE = [
    "# (subject)",
    "## (date)",
    "",
    "***",
  ]

  def prepare_template_file
    template_file = default_template

    FileUtils.mkdir_p(File.dirname(template_file))
    File.open(template_file, "w") { |f| f.write(TEMPLATE.join("\n")) }
  end

  def remove_template_file
    FileUtils.rm_f(default_template)
  end

  def default_template
    template_dir = File.join(@conf_rw[:config_home], "templates")
    File.expand_path("default.md", template_dir)
  end

end
