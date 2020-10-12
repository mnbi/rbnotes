require "test_helper"

class RbnotesTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rbnotes::VERSION
    refute_nil ::Rbnotes::RELEASE
  end

  def test_that_it_has_an_error_class
    assert_raises(Rbnotes::Error) {
      raise Rbnotes::Error, "something wrong"
    }
  end
end
