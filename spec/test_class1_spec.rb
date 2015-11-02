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

      var_2165592540 = "test"
      another_object = TestClass1.new(var_2165592540)
      var_2165586880 = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}

      @fixture = TestClass1.new(var_2165586880)

    end

    it 'should pass current expectations' do

      var_2165592540 = "test"
      another_object = TestClass1.new(var_2165592540)
      var_2165586880 = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}
      var_2159732800 = Proc.new { |message|
            var_2165586880
      }

      var_8 = nil
      var_2159719320 = Proc.new { 
            # Variable return values ... can't figure out what goes in here...
      }


      # TestClass1#print_message when passed  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass1#print_message when passed  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass1#set_block when passed  should return #<Pretentious::RecordedProc:0x000001017568c0@example.rb:73>
      expect( @fixture.set_block  &var_2159732800 ).to eq(var_2159732800)

      # TestClass1#call_block when passed  should return {:hello=>"world", :test=>#<TestClass1:0x0000010228a1d8 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2165592540=>"message"}>, :arr_1=>[1, 2, 3, 4, 5, #<TestClass1:0x0000010228a1d8 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2165592540=>"message"}>], :sub_hash=>{:yes=>true, :obj=>#<TestClass1:0x0000010228a1d8 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2165592540=>"message"}>}}
      expect( @fixture.call_block  &var_2159719320 ).to eq(var_2165586880)

    end
  end

end
