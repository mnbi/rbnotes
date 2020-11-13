require "test_helper"

class RbnotesCommandsPickTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb

  def setup
    @conf = CONF_RO.dup
    @conf[:picker] = File.expand_path("fake_picker", __dir__)
  end

  def test_it_can_pick_one_item
    result = execute(:pick, [], @conf)
    refute result.empty?
    assert_equal 1, result.split("\n").size
    assert_match %r([0-9]{14}), result[0, 14]
  end

  def test_it_just_print_list_when_no_picker_set
    @conf.delete(:picker)
    result = execute(:pick, [], @conf)
    refute result.empty?
    assert_operator 1, :<=, result.split("\n").size
    assert_match %r([0-9]{14}), result[0, 14]
  end

end
