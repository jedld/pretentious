require 'spec_helper'

RSpec.describe TestClass1 do

  context 'Scenario 1' do
    before do


      @fixture = TestClass1.new("test")

    end

    it 'should pass current expectations' do


      # TestClass1#message when passed  should return test
      expect( @fixture.message ).to eq("test")

    end
  end

  context 'Scenario 2' do
    before do

      var_2165841820 = "test"
      another_object = TestClass1.new(var_2165841820)
      var_2165836120 = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}

      @fixture = TestClass1.new(var_2165836120)

    end

    it 'should pass current expectations' do

      var_2165841820 = "test"
      another_object = TestClass1.new(var_2165841820)
      var_2165836120 = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}
      var_2165757580 = Proc.new { |message|
            var_2165836120
      }

      e = nil
      var_2165747260 = Proc.new { 
            # Variable return values ... can't figure out what goes in here...
      }


      # TestClass1#print_message when passed  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass1#print_message when passed  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass1#set_block when passed  should return #<Pretentious::RecordedProc:0x000001022d5e30@example.rb:73>
      expect( @fixture.set_block  &var_2165757580 ).to eq(var_2165757580)

      # TestClass1#call_block when passed  should return {:hello=>"world", :test=>#<TestClass1:0x00000102303d80 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2165841820=>"message"}>, :arr_1=>[1, 2, 3, 4, 5, #<TestClass1:0x00000102303d80 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2165841820=>"message"}>], :sub_hash=>{:yes=>true, :obj=>#<TestClass1:0x00000102303d80 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2165841820=>"message"}>}}
      expect( @fixture.call_block  &var_2165747260 ).to eq(var_2165836120)

      # TestClass1#something_is_wrong when passed  should return StandardError
      expect { @fixture.something_is_wrong }.to raise_error

    end
  end

end
