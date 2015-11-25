require 'spec_helper'

RSpec.describe TestClass3 do

  context 'Scenario 1' do
    before do

      var_2166230260 = "test"
      another_object = TestClass1.new(var_2166230260)
      args = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}
      test_class_one = TestClass1.new(args)
      args_1 = "This is message 2"
      test_class_two = TestClass2.new(args_1)

      @fixture = TestClass3.new(test_class_one, test_class_two)

    end

    it 'should pass current expectations' do

      # TestClass3#show_messages  should return awesome!!!
      expect( @fixture.show_messages ).to eq("awesome!!!")

    end
  end

  context 'Scenario 2' do
    before do

      var_2166230260 = "test"
      another_object = TestClass1.new(var_2166230260)
      args = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}
      test_class_one = TestClass1.new(args)
      args_1 = "This is message 2"
      test_class_two = TestClass2.new(args_1)

      @fixture = TestClass3.new(test_class_one, test_class_two)

    end

    it 'should pass current expectations' do

      # TestClass3#show_messages  should return awesome!!!
      expect( @fixture.show_messages ).to eq("awesome!!!")

    end
  end

end
