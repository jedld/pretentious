# This file was automatically generated by the pretentious gem
require 'minitest_helper'
require 'minitest/autorun'

class FibonacciTest < Minitest::Test
end

class FibonacciScenario1 < FibonacciTest
  def setup
    @fixture = Fibonacci.new
  end

  def test_current_expectation
    n = 1
    n_1 = 2
    n_2 = 3
    n_3 = 4
    n_4 = 5

    # Fibonacci#fib when passed n = 1 should return 1
    assert_equal 1, @fixture.fib(n)

    # Fibonacci#fib when passed n = 2 should return 1
    assert_equal 1, @fixture.fib(n_1)

    # Fibonacci#fib when passed n = 3 should return 2
    assert_equal 2, @fixture.fib(n_2)

    # Fibonacci#fib when passed n = 4 should return 3
    assert_equal 3, @fixture.fib(n_3)

    # Fibonacci#fib when passed n = 5 should return 5
    assert_equal 5, @fixture.fib(n_4)
  end
end

class FibonacciScenario2 < FibonacciTest
  def test_current_expectation
    # Fibonacci::say_hello  should return 'hello'
    assert_equal 'hello', Fibonacci.say_hello
  end
end