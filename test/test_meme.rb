require 'test_helper'
require "minitest/autorun"

class TestMeme < Minitest::Test
end

class Scenario1 < TestMeme
  def setup
    @fixture = Meme.new
  end

  def test_current_expectation

      # Meme#i_can_has_cheezburger?  should return OHAI!
    assert_equal "OHAI!", @fixture.i_can_has_cheezburger?

      # Meme#will_it_blend?  should return YES!
    assert_equal "YES!", @fixture.will_it_blend?

  end
end

