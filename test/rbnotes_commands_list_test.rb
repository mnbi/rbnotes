require "io/console/size"
require "unicode/display_width"
require "test_helper"

class RbnotesCommandsListTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb

  def setup
    @conf_rw = CONF_RW.dup
    @conf_rw[:repository_name] = "repo_list_test"
  end

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

  def test_that_it_can_list_with_given_pattern
    files = Dir.glob("#{repo_path(CONF_RO)}/**/*.md").map{|f| File.basename(f)}

    result = execute(:list, ["20201012"], CONF_RO)

    refute result.empty?
    result.lines.each { |line|
      timestamp_str = line[0, 18].rstrip
      assert files.include?("#{timestamp_str}.md")
    }
  end

  def test_that_it_can_list_with_year_only_pattern
    pattern = "2019"
    compare_entries_size("#{pattern}*.md", pattern)
  end

  def test_that_it_can_list_with_date_only_pattern
    pattern = "1012"
    compare_entries_size("*#{pattern}*.md", pattern)
  end

  def test_it_accpets_today_as_arg
    keyword = "today"
    prepare_today_note(["today"])
    result = execute(:list, [keyword], @conf_rw)
    assert result.include?(today_stamp_pattern)
  end

  def test_it_accpets_to_as_abbreviation
    keyword = "to"
    prepare_today_note(["today"])
    result = execute(:list, [keyword], @conf_rw)
    assert result.include?(today_stamp_pattern)
  end

  def test_it_accpets_yesterday_as_arg
    keyword = "yesterday"
    prepare_yesterday_note(["yesterday"])
    result = execute(:list, [keyword], @conf_rw)
    assert result.include?(yesterday_stamp_pattern)
  end

  def test_it_accpets_ye_as_abbreviation
    keyword = "ye"
    prepare_yesterday_note(["yesterday"])
    result = execute(:list, [keyword], @conf_rw)
    assert result.include?(yesterday_stamp_pattern)
  end

  def test_it_accpets_this_week_as_arg
    keyword = "this_week"
    prepare_this_week_notes(["this week"])
    result = execute(:list, [keyword], @conf_rw)
    this_week_stamp_patterns.each {|pat|
      assert result.include?(pat)
    }
  end

  def test_it_accpets_tw_as_abbreviation_for_this_week
    keyword = "tw"
    prepare_this_week_notes(["this week"])
    result = execute(:list, [keyword], @conf_rw)
    this_week_stamp_patterns.each {|pat|
      assert result.include?(pat)
    }
  end

  def test_it_accpets_last_week_as_arg
    keyword = "last_week"
    prepare_last_week_notes(["last week"])
    result = execute(:list, [keyword], @conf_rw)
    last_week_stamp_patterns.each {|pat|
      assert result.include?(pat)
    }
  end

  def test_it_accpets_lw_as_abbreviation_for_last_week
    keyword = "lw"
    prepare_last_week_notes(["last week"])
    result = execute(:list, [keyword], @conf_rw)
    last_week_stamp_patterns.each {|pat|
      assert result.include?(pat)
    }
  end

  # [issue #54]
  def test_it_sorts_correctly_with_keyword_this_week
    conf = @conf_rw.dup
    conf[:repository_name] = "repo_list_keyword_sort"
    keyword = "this_week"
    stamp_patterns = this_week_stamp_patterns
    stamp_patterns.sort{|a, b| a <=> b}.each { |pat|
      stamp = "#{pat}090909"
      text = ["#{stamp}:sort for #{keyword}"]
      prepare_note(stamp, text, repo_path(conf))
    }
    result = execute(:list, [keyword], conf)
    result_patterns = result.lines(chomp: true).map {|l| l[0, 8]}
    assert_equal stamp_patterns.sort{|a, b| b <=> a}, result_patterns
  end

  private
  def extract_subject(file)
    content = File.readlines(file)
    content[0]
  end

  def compare_entries_size(glob_pattern, pattern)
    files = Dir.glob(File.join("#{repo_path(CONF_RO)}", "**", glob_pattern)).map{|f| File.basename(f)}
    result = execute(:list, [pattern], CONF_RO)
    assert_equal files.size, result.lines.size
  end

  def prepare_today_note(text)
    today = Textrepo::Timestamp.new(Time.now).to_s
    prepare_note(today, text, repo_path(@conf_rw))
  end

  require "date"

  def prepare_yesterday_note(text)
    ye_pattern = "#{yesterday_stamp_pattern}010203"
    prepare_note(ye_pattern, text, repo_path(@conf_rw))
  end

  def prepare_this_week_notes(text)
    this_week_stamp_patterns.each { |pat|
      stamp = "#{pat}010203"
      prepare_note(stamp, text, repo_path(@conf_rw))
    }
  end

  def prepare_last_week_notes(text)
    last_week_stamp_patterns.each { |pat|
      stamp = "#{pat}040506"
      prepare_note(stamp, text, repo_path(@conf_rw))
    }
  end

  def today_stamp_pattern
    Time.now.strftime("%Y%m%d")
  end

  def yesterday_stamp_pattern
    to = Time.now
    ye = Time.new(*Date.new(to.year, to.mon, to.day).prev_day.strftime("%Y-%m-%d").split("-"))
    ye.strftime("%Y%m%d")
  end

  def wday(time)
    (time.wday - 1) % 7
  end

  def dates_in_week(start_date)
    dates = [start_date]
    1.upto(6) { |i| dates << start_date.next_day(i) }
    dates.map { |d| d.strftime("%Y%m%d") }
  end

  def this_week_stamp_patterns
    to = Time.now
    start_of_this_week = Date.new(to.year, to.mon, to.day).prev_day(wday(to))
    dates_in_week(start_of_this_week)
  end

  def last_week_stamp_patterns
    to = Time.now
    start_of_this_week = Date.new(to.year, to.mon, to.day).prev_day(wday(to))
    dates_in_week(start_of_this_week.prev_day(7))
  end
end
