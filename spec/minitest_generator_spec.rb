require 'spec_helper'

RSpec.describe Pretentious::Generator do

  context 'Pretentious::Deconstructor#build_tree' do

    before do
      @fixture = Pretentious::Generator.new
      Pretentious::Generator.test_generator = Pretentious::MinitestGenerator
    end

    it "classes should have a stub class section" do
      Fibonacci._stub(String)
      expect(Fibonacci._get_mock_classes).to eq([String])
    end

    it "tracks object calls" do
      result = Pretentious::Generator.generate_for(Fibonacci) do
        Fibonacci.say_hello
      end
      expect(result).to eq({Fibonacci =>{output: "require 'test_helper'\nrequire \"minitest/autorun\"\n\nclass TestFibonacci < Minitest::Test\nend\n\n  def test_current_expectation\n\n      # Fibonacci::say_hello  should return hello\n    assert_equal \"hello\", Fibonacci.say_hello\n\n  end\n",
        generator: Pretentious::MinitestGenerator }})
    end

  end

end
