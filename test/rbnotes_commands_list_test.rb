require "test_helper"

class RbnotesCommandsListTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def setup
    @conf_ro = {
      :repository_type => :file_system,
      :repository_name => "fixtures/test_repo",
      :repository_base => File.expand_path(__dir__),
    }
  end

  def test_that_it_can_list_up_all_notes
    files = [
      "20201012005000.md",
      "20201012005000_089.md",
      "20201012005001.md",
      "20201012005001_089.md",
      "20201012005002.md",
      "20201012005002_089.md",
    ]
    cmd = load_cmd(:list)
    result = ""
    StringIO.open(result, "w") { |out|
      $stdout = out
      cmd.execute([], @conf_ro)
      $stdout = STDOUT
    }

    refute result.empty?
    result.lines.each { |line|
      timestamp_str = line[0, 18].rstrip

      assert files.include?("#{timestamp_str}.md")

      truncated = line[20..-1]
      repo_path = File.expand_path("fixtures/test_repo", __dir__)
      note_path = File.expand_path("2020/10/#{timestamp_str}.md", repo_path)
      subject = extract_subject(note_path)

      assert subject.include?(truncated)
    }
  end

  private
  def extract_subject(file)
    content = File.readlines(file)
    content[0]
  end
end

