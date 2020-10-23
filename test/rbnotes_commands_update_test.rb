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
    timestamp = "20201022000000"
    prepare_note(timestamp, ["Hello!"], repo_path(@conf_rw))

    result = execute("update", [timestamp], @conf_rw)

    # extract the new timestamp from the execution result
    newstamp = /-> ([0-9]+)\]/.match(result).to_a[1]
    dst_note_path = timestamp_to_path(newstamp, repo_path(@conf_rw))
    assert FileTest.exist?(dst_note_path)

    # the following assertion depends on the `fake_editor` behavior
    headline = File.readlines(dst_note_path)[0]
    assert headline.include?("rbnotes")
  end

  def test_that_it_does_nothing_when_an_empty_text_was_given
    conf = @conf_rw.dup
    conf[:editor] = File.expand_path("fake_editor_empty_content", __dir__)

    # prepare a note to update
    timestamp = "20201022000001"
    prepare_note(timestamp, ["Hi!"], repo_path(conf))

    result = execute("update", [timestamp], conf)

    # `result` must contain a message which says it does nothing
    assert result.include?("Nothing is updated")
  end

end
