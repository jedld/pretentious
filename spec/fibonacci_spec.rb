require 'spec_helper'

RSpec.describe Fibonacci do

  context 'Scenario 1' do
    before do


      @fixture = Fibonacci.new

    end

    it 'should pass current expectations' do

      n = 1
      n_1 = 2
      n_2 = 3
      n_3 = 4
      n_4 = 5
      n_5 = 6
      n_6 = 7
      n_7 = 8
      n_8 = 9
      n_9 = 10

      # Fibonacci#fib when passed n = 1 should return 1
      expect( @fixture.fib(n) ).to eq(1)

      # Fibonacci#fib when passed n = 2 should return 1
      expect( @fixture.fib(n_1) ).to eq(1)

      # Fibonacci#fib when passed n = 3 should return 2
      expect( @fixture.fib(n_2) ).to eq(2)

      # Fibonacci#fib when passed n = 4 should return 3
      expect( @fixture.fib(n_3) ).to eq(3)

      # Fibonacci#fib when passed n = 5 should return 5
      expect( @fixture.fib(n_4) ).to eq(5)

      # Fibonacci#fib when passed n = 6 should return 8
      expect( @fixture.fib(n_5) ).to eq(8)

      # Fibonacci#fib when passed n = 7 should return 13
      expect( @fixture.fib(n_6) ).to eq(13)

      # Fibonacci#fib when passed n = 8 should return 21
      expect( @fixture.fib(n_7) ).to eq(21)

      # Fibonacci#fib when passed n = 9 should return 34
      expect( @fixture.fib(n_8) ).to eq(34)

      # Fibonacci#fib when passed n = 10 should return 55
      expect( @fixture.fib(n_9) ).to eq(55)

    end
  end

    it 'should pass current expectations' do


      # Fibonacci::say_hello when passed  should return hello
      expect( Fibonacci.say_hello ).to eq("hello")

    end
end
