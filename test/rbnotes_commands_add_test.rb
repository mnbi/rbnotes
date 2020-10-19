require "test_helper"

class RbnotesCommandsAddTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def setup
    @conf_rw = CONF_RW.dup
    @conf_rw[:repository_name] = "test_repo_for_add"
    @conf_rw[:editor] = File.expand_path("fake_editor", __dir__)
  end

  def test_that_it_can_create_a_new_note
    result = execute("add", [], @conf_rw)

    timestamp = /[A-z ]+\[([0-9]+)\]/.match(result).to_a[1]
    refute timestamp.nil?

    note_path = timestamp_to_path(timestamp, repo_path(@conf_rw))
    assert FileTest.exist?(note_path)

    FileUtils.rm_f(note_path)   # prevent to fail other test for "add"
  end

  def test_that_it_fails_to_crete_with_empty_content
    conf = @conf_rw.dup
    conf[:editor] = File.expand_path("fake_editor_empty_content", __dir__)

    result = execute("add", [], conf)
    assert result.include?("empty text")
  end
end
