require 'spec_helper'

RSpec.describe Pretentious::Generator do

  context 'Pretentious::Generator' do

    before do
      @fixture = Pretentious::Generator.new
      Pretentious::Generator.test_generator = Pretentious::RspecGenerator
    end


    it "uses instance variables when used both in test and in fixtures" do
      call_artifacts = Pretentious::Generator.generate_for(TestClass1) do
        message = {test: "message"}
        object = TestClass1.new(message)
        object.return_self(message)
      end
      expect(call_artifacts[TestClass1][:output]).to eq("# This file was automatically generated by the pretentious gem\nrequire 'spec_helper'\n\nRSpec.describe TestClass1 do\n  context 'Scenario 1' do\n    before do\n      @message = { test: 'message' }\n      @fixture = TestClass1.new(@message)\n    end\n\n    it 'should pass current expectations' do\n      # TestClass1#return_self when passed message = {:test=>\"message\"} should return {:test=>\"message\"}\n      expect(@fixture.return_self(@message)).to eq(@message)\n    end\n  end\n\nend\n")
    end

    it "classes should have a stub class section" do
      Fibonacci._stub(String)
      expect(Fibonacci._get_mock_classes).to eq([String])
    end

    it "tracks object calls" do
      klass = Fibonacci

      result = Pretentious::Generator.generate_for(Fibonacci) do
        expect(klass == Fibonacci).to_not be
        Fibonacci.say_hello
      end
      #should clean up after block
      expect(klass == Fibonacci).to be

      #should still work
      fib = Fibonacci.new
      expect(fib.fib(6)).to eq(8)

      expect(result).to eq(
        Fibonacci => { output:"# This file was automatically generated by the pretentious gem\nrequire 'spec_helper'\n\nRSpec.describe Fibonacci do\n    it 'should pass current expectations' do\n      # Fibonacci::say_hello  should return hello\n      expect(Fibonacci.say_hello).to eq('hello')\n    end\n\nend\n",
                       generator: Pretentious::RspecGenerator })
    end
  end

  context "unobstrusive generator" do
    it "declare watched classes beforehand and capture when certain methods are invoked" do
      #declare intention
      Pretentious.on(TestClass5).method_called(:test_method).spec_for(Fibonacci) do |results|
        expect(results[Fibonacci][:output]).to eq("# This file was automatically generated by the pretentious gem\nrequire 'spec_helper'\n\nRSpec.describe Fibonacci do\n  context 'Scenario 1' do\n    before do\n      @fixture = Fibonacci.new\n    end\n\n    it 'should pass current expectations' do\n      # Fibonacci#fib when passed n = 5 should return 5\n      expect(@fixture.fib(5)).to eq(5)\n    end\n  end\n\nend\n")
      end

      expect(Pretentious::Generator).to receive(:generate_for).with(Fibonacci).and_call_original
      #execute code
      class_that_uses_fib = TestClass5.new
      result = class_that_uses_fib.test_method
      expect(result).to eq(5)
    end

    it "outputs to a file when no block is given" do
      Pretentious.on(TestClass5).method_called(:test_method).spec_for(Fibonacci)

      expect(Pretentious::Trigger).to receive(:output_file)

      class_that_uses_fib = TestClass5.new
      result = class_that_uses_fib.test_method
      expect(result).to eq(5)
    end

    it "works on class methods" do
      Pretentious.on(TestClass5).class_method_called(:class_test_method).spec_for(Fibonacci)

      expect(Pretentious::Trigger).to receive(:output_file)
      expect(Pretentious::Generator).to receive(:generate_for).with(Fibonacci).and_call_original
      result = TestClass5.class_test_method

      expect(result).to eq(8)
    end

    it "works on multiple methods" do
      Pretentious.on(TestClass5).method_called(:test_method, :test_method2).spec_for(Fibonacci)

      expect(Pretentious::Trigger).to receive(:output_file).twice
      expect(Pretentious::Generator).to receive(:generate_for).twice.with(Fibonacci).and_call_original

      class_that_uses_fib = TestClass5.new
      result1 = class_that_uses_fib.test_method
      result2 = class_that_uses_fib.test_method2

      expect(result1).to eq(5)
      expect(result2).to eq(34)

    end
  end
end
