require 'spec_helper'

RSpec.describe TestClass1 do

  context 'Scenario 1' do
    before do


      @fixture = TestClass1.new("test")

    end

    it 'should pass current expectations' do


    end
  end

  context 'Scenario 2' do
    before do

      var_2167529620 = "test"
      another_object = TestClass1.new(var_2167529620)
      var_2167516320 = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}

      @fixture = TestClass1.new(var_2167516320)

    end

    it 'should pass current expectations' do


      # TestClass1#print_message when passed  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass1#print_message when passed  should return 
      expect( @fixture.print_message ).to be_nil

    end
  end

end
