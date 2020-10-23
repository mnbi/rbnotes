require "io/console/size"
require "unicode/display_width"
require "test_helper"

class RbnotesCommandsListTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def test_that_it_can_list_up_all_notes
    files = Dir.glob("#{repo_path(CONF_RO)}/**/*.md").map{|f| File.basename(f)}

    result = execute(:list, [], CONF_RO)

    refute result.empty?
    result.lines.each { |line|
      timestamp_str = line[0, 18].rstrip

      assert files.include?("#{timestamp_str}.md")

      truncated = line[20..-1].chomp
      note_path = timestamp_to_path(timestamp_str, repo_path(CONF_RO))
      subject = extract_subject(note_path)

      assert subject.include?(truncated)
    }
  end

  def test_that_it_can_truncate_very_long_subject
    # prepare test data
    text_dir = File.expand_path("fixtures/text", __dir__)
    src_files = ["very_long_subject.md", "very_long_subject_ja.md"].map { |f|
      File.expand_path(f, text_dir)
    }

    conf = CONF_RO.dup
    conf[:repository_base] = File.expand_path("sandbox", __dir__)

    sandbox_repo = repo_path(conf)
    timestamp_strs = ["20201013173800", "20201013173900"]
    src_files.each_with_index { |f, i|
      stmp_str = timestamp_strs[i]
      prepare_note_from_file(stmp_str, f, sandbox_repo)
    }

    # execute test
    result = execute(:list, [], conf)
    result.split.each { |line|
      assert IO.console_size[1] >= Unicode::DisplayWidth.of(line)
    }
  end

  private
  def extract_subject(file)
    content = File.readlines(file)
    content[0]
  end
end

