require "test_helper"

class RbnotesCommandsImportTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def teardown
    FileUtils.rm_r(repo_path(CONF_RW))
  end

  def test_that_it_can_import_an_existing_file
    src_file = File.expand_path("fixtures/text/apple.md", __dir__)

    expected = expected_path(src_file)
    refute FileTest.exist?(expected)

    # execute rbnotes command
    execute(:import, [src_file], CONF_RW)

    assert FileTest.exist?(expected)
    assert FileUtils.identical?(src_file, expected)
  end

  def test_that_it_can_import_the_given_file_even_if_its_timestamp_is_already_attached_to_the_different_note
    src_file = File.expand_path("fixtures/text/cpu.md", __dir__)
    other_file = File.expand_path("fixtures/text/programming_languages.md", __dir__)

    # prepare a test situation
    target_path = expected_path(src_file)
    FileUtils.mkdir_p(File.dirname(target_path))
    FileUtils.cp(other_file, target_path)

    expected = expected_path(src_file).sub(/\.md/, "_001.md")
    refute FileTest.exist?(expected)

    # execute rbnotes command
    execute(:import, [src_file], CONF_RW)

    assert FileTest.exist?(expected)
    assert FileUtils.identical?(src_file, expected)
  end

  private
  def expected_path(org_file)
    st = File::Stat.new(org_file)
    btime = st.respond_to?(:birthtime) ? st.birthtime : st.mtime
    timestamp_str = btime.strftime("%Y%m%d%H%M%S")
    dirname = btime.strftime("%Y/%m")

    File.expand_path("#{dirname}/#{timestamp_str}.md", repo_path(CONF_RW))
  end
end
