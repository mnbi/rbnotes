require "test_helper"

class RbnotesCommandsAddTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def setup
    @conf_rw = CONF_RW.dup
    @conf_rw[:repository_name] = "test_repo_for_add"
    @conf_rw[:editor] = File.expand_path("fake_editor", __dir__)
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

end
