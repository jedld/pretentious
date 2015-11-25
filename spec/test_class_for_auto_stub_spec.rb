require 'spec_helper'

RSpec.describe TestClassForAutoStub do

  context 'Scenario 1' do
    before do

      @fixture = TestClassForAutoStub.new

    end

    it 'should pass current expectations' do

      var_2157894280 = ["Hello Glorious world", "HI THERE!!!!"]

      allow_any_instance_of(ClassUsedByTestClass).to receive(:stubbed_method).and_return("Hello Glorious world")
      allow_any_instance_of(AnotherClassUsedByTestClass).to receive(:get_message).and_return("HI THERE!!!!")

      # TestClassForAutoStub#method_that_uses_the_class_to_stub  should return ["Hello Glorious world", "HI THERE!!!!"]
      expect( @fixture.method_that_uses_the_class_to_stub ).to eq(["Hello Glorious world", "HI THERE!!!!"])

    end
  end

end
