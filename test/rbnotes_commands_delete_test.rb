require "test_helper"

class RbnotesCommandsDeleteTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def setup
    @conf_rw= CONF_RW.dup
    @conf_rw[:repository_name] = "test_repo_for_delete"
  end

  def test_that_it_can_delete_the_specified_note
    target_stamp = "20201016132900"

    fixture_text_dir = File.expand_path("text", CONF_RO[:repository_base])
    src_path = File.expand_path("apple.md", fixture_text_dir)

    dst_path = prepare_note_from_file(target_stamp, src_path, repo_path(@conf_rw))

    result = execute(:delete, [target_stamp], @conf_rw)

    assert result.include?("Delete")
    assert result.include?(target_stamp)
    refute FileTest.exist?(dst_path)
  end

  def test_that_it_raises_when_non_existing_timestamp_was_specified
    stamp = "20201016132900_999"

    result = execute(:delete, [stamp], @conf_rw)
    assert result.include?("missing timestamp")
  end
end
