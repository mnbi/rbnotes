require "test_helper"

class RbnotesCommandsDeleteTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def setup
    @conf_rw= CONF_RW
    @target_stamp = "20201016132900"

    fixture_text_dir = File.expand_path("text", CONF_RO[:repository_base])
    src_path = File.expand_path("apple.md", fixture_text_dir)

    dest_dir = File.join([@conf_rw[:repository_base],
                          @conf_rw[:repository_name],
                          "2020",
                          "10"])
    @dest_path = File.expand_path("#{@target_stamp}.md", dest_dir)

    unless FileTest.exist?(@dest_path)
      FileUtils.mkdir_p(File.dirname(@dest_path))
      FileUtils.copy_file(src_path, @dest_path)
    end
  end

  def test_that_it_can_delete_the_specified_note
    assert FileTest.exist?(@dest_path)

    result = execute(:delete, [@target_stamp], @conf_rw)

    assert result.include?("Delete")
    assert result.include?(@target_stamp)
    refute FileTest.exist?(@dest_path)
  end

  def test_that_it_raises_when_non_existing_timestamp_was_specified
    stamp = "20201016132900_999"

    result = execute(:delete, [stamp], @conf_rw)
    assert result.include?("missing timestamp")
  end
end
