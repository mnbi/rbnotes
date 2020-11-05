require "test_helper"

class RbnotesCommandsUpdateTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def setup
    @conf_rw = CONF_RW.dup
    @conf_rw[:repository_name] = "test_repo_for_update"
    @conf_rw[:editor] = File.expand_path("fake_editor", __dir__)
  end

  def test_that_it_can_update_a_note
    # prepare a note to update
    timestamp = "2020-10-22 00:00:00".tr("- :", "")
    prepare_note(timestamp, ["Hello!"], repo_path(@conf_rw))

    result = execute(:update, [timestamp], @conf_rw)
    assert_success_to_update(result)
  end

  def test_that_it_does_nothing_when_an_empty_text_was_given
    conf = @conf_rw.dup
    conf[:editor] = File.expand_path("fake_editor_empty_content", __dir__)

    # prepare a note to update
    timestamp = "2020-10-22 00:00:01".tr("- :", "")
    prepare_note(timestamp, ["Hi!"], repo_path(conf))

    result = execute(:update, [timestamp], conf)

    # `result` must contain a message which says it does nothing
    assert result.include?("Nothing is updated")
  end

  def test_that_it_reads_arg_from_stdin_when_no_args
    timestamp_str = "2020-10-29 17:00:00".tr("- :", "")
    prepare_note(timestamp_str, ["# Do you read me?"], repo_path(@conf_rw))

    $stdin = StringIO.new(timestamp_str)
    result = execute(:update, [], @conf_rw)
    $stdin = STDIN

    dst_note_path = extract_note_path(result)
    assert_path_exists dst_note_path
  end

  def test_it_keeps_the_timestamp_with_keep_option
    timestamp_str = "2020-11-05 16:00:00".tr("- :", "")
    prepare_note(timestamp_str, ["Update the content", "Keep the timestamp"], repo_path(@conf_rw))

    result = execute(:update, ["-k", timestamp_str], @conf_rw)
    assert_success_to_update(result)
  end

  def test_it_keeps_the_timestamp_with_long_keep_option
    timestamp_str = "2020-11-05 16:01:00".tr("- :", "")
    prepare_note(timestamp_str, ["Update the content", "Keep the timestamp"], repo_path(@conf_rw))

    result = execute(:update, ["--keep", timestamp_str], @conf_rw)
    assert_success_to_update(result)
  end

  # [issue #35]
  def test_it_does_not_update_for_the_same_content
    conf = @conf_rw.dup
    conf[:editor] = File.expand_path("fake_editor_do_nothing", __dir__)

    timestamp_str = "2020-11-02 14:49:00".tr("- :", "")
    prepare_note(timestamp_str,
                 ["# Sample note", "This is a sample."],
                 repo_path(conf))
    result = execute(:update, [timestamp_str], conf)
    assert result.empty?
  end

  private
  # extract the new timestamp from the execution result
  def extract_note_path(str)
    timestamp_str = /([0-9]+)\]/.match(str).to_a[1]
    timestamp_to_path(timestamp_str, repo_path(@conf_rw))
  end

  def assert_success_to_update(result)
    dst_note_path = extract_note_path(result)
    assert_path_exists dst_note_path

    # the following assertion depends on the `fake_editor` behavior
    headline = File.readlines(dst_note_path)[0]
    assert headline.include?("rbnotes")
  end
end
