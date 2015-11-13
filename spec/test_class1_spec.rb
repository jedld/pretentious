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

      var_2167280720 = "test"
      another_object = TestClass1.new(var_2167280720)
      var_2167280420 = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}

      @fixture = TestClass1.new(var_2167280420)

    end

    it 'should pass current expectations' do

      var_2167280720 = "test"
      another_object = TestClass1.new(var_2167280720)
      var_2167280420 = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}
      var_2167116520 = Proc.new { |message|
            var_2167280420
      }

      e = nil
      var_2167112020 = Proc.new { 
            # Variable return values ... can't figure out what goes in here...
      }


      # TestClass1#print_message  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass1#print_message  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass1#set_block  should return #<Pretentious::RecordedProc:0x00000102570488@example.rb:71>
      expect( @fixture.set_block  &var_2167116520 ).to eq(var_2167116520)

      # TestClass1#call_block  should return {:hello=>"world", :test=>#<TestClass1:0x000001025c26e8 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2167280720=>"message"}>, :arr_1=>[1, 2, 3, 4, 5, #<TestClass1:0x000001025c26e8 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2167280720=>"message"}>], :sub_hash=>{:yes=>true, :obj=>#<TestClass1:0x000001025c26e8 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2167280720=>"message"}>}}
      expect( @fixture.call_block  &var_2167112020 ).to eq(var_2167280420)

      # TestClass1#something_is_wrong  should return StandardError
      expect { @fixture.something_is_wrong }.to raise_error

      # TestClass1#just_returns_true  should return true
      expect( @fixture.just_returns_true ).to be true

    end
  end

end
