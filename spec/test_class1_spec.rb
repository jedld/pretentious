require 'spec_helper'

RSpec.describe TestClass1 do

  context 'Scenario 1' do
    before do


      @fixture = TestClass1.new("test")

    end

    it 'should pass current expectations' do


      # TestClass1#message  should return test
      expect( @fixture.message ).to eq("test")

    end
  end

  context 'Scenario 2' do
    before do

      var_2194392760 = "test"
      another_object = TestClass1.new(var_2194392760)
      var_2194378360 = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}

      @fixture = TestClass1.new(var_2194378360)

    end

    it 'should pass current expectations' do

      var_2194392760 = "test"
      another_object = TestClass1.new(var_2194392760)
      var_2194378360 = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}
      var_2194251500 = Proc.new { |message|
            var_2194378360
      }

      e = nil
      var_2194247280 = Proc.new { 
            # Variable return values ... can't figure out what goes in here...
      }


      # TestClass1#print_message  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass1#print_message  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass1#set_block  should return #<Pretentious::RecordedProc:0x00000105931ec0@example.rb:73>
      expect( @fixture.set_block  &var_2194251500 ).to eq(var_2194251500)

      # TestClass1#call_block  should return {:hello=>"world", :test=>#<TestClass1:0x00000105978b90 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2194392760=>"message"}>, :arr_1=>[1, 2, 3, 4, 5, #<TestClass1:0x00000105978b90 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2194392760=>"message"}>], :sub_hash=>{:yes=>true, :obj=>#<TestClass1:0x00000105978b90 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2194392760=>"message"}>}}
      expect( @fixture.call_block  &var_2194247280 ).to eq(var_2194378360)

      # TestClass1#something_is_wrong  should return StandardError
      expect { @fixture.something_is_wrong }.to raise_error

      # TestClass1#just_returns_true  should return true
      expect( @fixture.just_returns_true ).to be true

    end
  end

end
