require 'spec_helper'

RSpec.describe Pretentious::Generator do

  context 'Pretentious::Deconstructor#build_tree' do

    before do
      @fixture = Pretentious::Generator.new
    end

    it "classes should have a mock class section" do
      Fibonacci._mock(String)
      expect(Fibonacci._get_mock_classes).to eq([String])
    end

    it "tracks object calls" do
      result = Pretentious::Generator.generate_for(Fibonacci) do
        Fibonacci.say_hello
      end
      expect(result).to eq({
        Fibonacci => "require 'spec_helper'\n\nRSpec.describe Fibonacci do\n\n    it 'should pass current expectations' do\n\n\n      # Fibonacci::say_hello  should return hello\n      expect( Fibonacci.say_hello ).to eq(\"hello\")\n\n    end\nend\n"
                           })
    end

    it "handles auto mocks" do
      result = Pretentious::Generator.generate_for(TestClass1._mock(TestClass2)) do
        test_class_2 = TestClass2.new("the message")
        test_class_1 = TestClass1.new(test_class_2)
        test_class_1.invoke_class
      end
      p result
    end
  end

end
