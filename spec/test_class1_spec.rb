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

      var_2157436060 = "test"
      another_object = TestClass1.new(var_2157436060)
      var_2157430640 = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}

      @fixture = TestClass1.new(var_2157430640)

    end

    it 'should pass current expectations' do

      var_2157436060 = "test"
      another_object = TestClass1.new(var_2157436060)
      var_2157430640 = {hello: "world", test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: {yes: true, obj: another_object}}
      var_2157617620 = Proc.new { |message|
            var_2157430640
      }

      e = nil
      var_2173948680 = Proc.new { 
            # Variable return values ... can't figure out what goes in here...
      }


      # TestClass1#print_message  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass1#print_message  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass1#set_block  should return #<Pretentious::RecordedProc:0x0000010327a868@example.rb:71>
      expect( @fixture.set_block  &var_2157617620 ).to eq(var_2157617620)

      # TestClass1#call_block  should return {:hello=>"world", :test=>#<TestClass1:0x000001012fb7a8 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2157436060=>"message"}>, :arr_1=>[1, 2, 3, 4, 5, #<TestClass1:0x000001012fb7a8 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2157436060=>"message"}>], :sub_hash=>{:yes=>true, :obj=>#<TestClass1:0x000001012fb7a8 @message="test", @_init_arguments={:params=>["test"]}, @_variable_names={2157436060=>"message"}>}}
      expect( @fixture.call_block  &var_2173948680 ).to eq(var_2157430640)

      # TestClass1#something_is_wrong  should return StandardError
      expect { @fixture.something_is_wrong }.to raise_error

      # TestClass1#just_returns_true  should return true
      expect( @fixture.just_returns_true ).to be true

    end
  end

end
