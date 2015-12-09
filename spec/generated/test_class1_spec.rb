# This file was automatically generated by the pretentious gem
require 'spec_helper'

RSpec.describe TestClass1 do
  context 'Scenario 1' do
    before do
      @fixture = TestClass1.new('test')
    end

    it 'should pass current expectations' do
      # TestClass1#message  should return test
      expect(@fixture.message).to eq('test')
    end
  end

  context 'Scenario 2' do
    before do
      @another_object = TestClass1.new('test')
      @message = { hello: 'world', test: @another_object, arr_1: [1, 2, 3, 4, 5, @another_object], sub_hash: { yes: true, obj: @another_object } }
      @fixture = TestClass1.new(@message)
    end

    it 'should pass current expectations' do
      a = proc { |message|
        @message
      }

      filewriter = nil
      b = proc { 
        # Variable return values ... can't figure out what goes in here...
      }

      # TestClass1#print_message  should return 
      expect(@fixture.print_message).to be_nil

      # TestClass1#set_block  should return #<Pretentious::RecordedProc:0x000001048ab790@example.rb:73>
      expect(@fixture.set_block  &a).to eq(a)

      # TestClass1#call_block  should return {:hello=>"world", :test=>#<TestClass1:0x00000101e36a78 @message="test", @_init_arguments={:params=>["test"], :params_types=>[[:req, :message]]}, @_variable_names={2163324440=>"message"}>, :arr_1=>[1, 2, 3, 4, 5, #<TestClass1:0x00000101e36a78 @message="test", @_init_arguments={:params=>["test"], :params_types=>[[:req, :message]]}, @_variable_names={2163324440=>"message"}>], :sub_hash=>{:yes=>true, :obj=>#<TestClass1:0x00000101e36a78 @message="test", @_init_arguments={:params=>["test"], :params_types=>[[:req, :message]]}, @_variable_names={2163324440=>"message"}>}}
      expect(@fixture.call_block  &b).to eq(@message)

      # TestClass1#something_is_wrong  should return StandardError
      expect { @fixture.something_is_wrong }.to raise_error

      # TestClass1#just_returns_true  should return true
      expect(@fixture.just_returns_true).to be true
    end
  end

  context 'Scenario 3' do
    before do
      @fixture = TestClass1.new('Hello')
    end

    it 'should pass current expectations' do
      another_object = TestClass1.new('test')
      # TestClass1#return_self when passed message = #<TestClass1:0x00000101e36a78> should return #<TestClass1:0x00000101e36a78>
      expect(@fixture.return_self(another_object)).to eq(another_object)
    end
  end

  context 'Scenario 4' do
    before do
      @message = TestClass1.new('test')
      @fixture = TestClass1.new(@message)
    end

    it 'should pass current expectations' do
      # TestClass1#message  should return #<TestClass1:0x00000101e36a78>
      expect(@fixture.message).to eq(@message)
    end
  end

end
