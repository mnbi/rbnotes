# coding: utf-8
require "test_helper"

class RbnotesCommandsListTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def test_that_it_can_search_word
    result = execute(:search, ["apple"], CONF_RO)
    assert_operator 0, :<, result.size
  end

  def test_that_it_can_search_regex
    result = execute(:search, ["80.*86"], CONF_RO)
    assert_operator 0, :<, result.size
  end

  def test_that_it_can_search_with_timestamp_pattern_full_qualified
    result = execute(:search, ["apple", "20201012005000"], CONF_RO)
    assert_operator 0, :<, result.size
  end

  def test_that_it_can_search_with_timestamp_pattern_yyyy
    result = execute(:search, ["ruby", "2020"], CONF_RO)
    assert_operator 0, :<, result.size
  end

  def test_that_it_can_search_with_timestamp_pattern_yyyymo
    result = execute(:search, ["表題", "202010"], CONF_RO)
    assert_operator 0, :<, result.size
  end

  def test_that_it_can_search_regex_with_timestamp_pattern_yyyymo
    result = execute(:search, ["[#]+ M[a-z][c-z]", "202010"], CONF_RO)
    assert_operator 0, :<, result.size
  end

  def test_that_it_can_search_with_timestamp_pattern_yyyymodd
    result = execute(:search, ["swift", "20201012"], CONF_RO)
    assert_operator 0, :<, result.size
  end

  def test_that_it_can_search_with_timestamp_pattern_modd
    result = execute(:search, ["iphone", "1012"], CONF_RO)
    assert_operator 0, :<, result.size
  end
end

