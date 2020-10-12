require "test_helper"

class RbnotesCommandsShowTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def setup
    @pager_out = File.expand_path("sandbox/show_pager.out", __dir__)
    @conf_ro = {
      :repository_type => :file_system,
      :repository_name => "fixtures/test_repo",
      :repository_base => File.expand_path(__dir__),
      :pager => "cat > #{@pager_out}",
    }
  end

  def test_that_it_can_show_the_specified_note
    files = [
      "20201012005000.md",
      "20201012005000_089.md",
    ]
    cmd = load_cmd(:show)

    files.each { |file|
      timestamp = file[0..-4]
      file = File.expand_path("fixtures/test_repo/2020/10/#{file}", __dir__)

      cmd.execute([timestamp], @conf_ro)

      assert FileUtils.identical?(file, @pager_out)
    }
  end
end
