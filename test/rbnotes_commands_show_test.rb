require "test_helper"

class RbnotesCommandsShowTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def setup
    @pager_out = File.expand_path("sandbox/show_pager.out", __dir__)
    @conf_ro = CONF_RO.dup
    @conf_ro[:pager] = "cat > #{@pager_out}"
  end

  def test_that_it_can_show_the_specified_note
    files = [
      "20201012005000.md",
      "20201012005000_089.md",
    ]
    cmd = load_cmd(:show)

    files.each { |file|
      timestamp_str = file[0..-4]
      subdir = File.join([0..3, 4..5].map{|r| timestamp_str[r]})
      file = File.join(repo_path(@conf_ro), subdir, file)

      cmd.execute([timestamp_str], @conf_ro)

      assert FileUtils.identical?(file, @pager_out)
    }
  end
end
