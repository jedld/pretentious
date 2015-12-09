# This file was automatically generated by the pretentious gem
require 'minitest_helper'
require "minitest/autorun"

class TestClass1Test < Minitest::Test
end

class TestClass1Scenario1 < TestClass1Test
  def setup
    @fixture = TestClass1.new('test')
  end

  def test_current_expectation
    # TestClass1#message  should return test
    assert_equal 'test', @fixture.message
  end
end

class TestClass1Scenario2 < TestClass1Test
  def setup
    @another_object = TestClass1.new('test')
    @message = { hello: 'world', test: @another_object, arr_1: [1, 2, 3, 4, 5, @another_object], sub_hash: { yes: true, obj: @another_object } }
    @fixture = TestClass1.new(@message)
  end

  def test_current_expectation
    a = proc { |message|
      @message
    }

    filewriter = nil
    b = proc { 
      # Variable return values ... can't figure out what goes in here...
    }


    # TestClass1#print_message  should return 
    assert_nil @fixture.print_message
    # TestClass1#print_message  should return 
    assert_nil @fixture.print_message

    # TestClass1#set_block  should return #<Pretentious::RecordedProc:0x000000012eb1d8@example.rb:73>
    assert_equal a, @fixture.set_block( &a)

    # TestClass1#call_block  should return {:hello=>"world", :test=>#<TestClass1:0x000000013740a0 @message="test", @_init_arguments={:params=>["test"], :params_types=>[[:req, :message]]}, @_variable_names={10199420=>"message"}>, :arr_1=>[1, 2, 3, 4, 5, #<TestClass1:0x000000013740a0 @message="test", @_init_arguments={:params=>["test"], :params_types=>[[:req, :message]]}, @_variable_names={10199420=>"message"}>], :sub_hash=>{:yes=>true, :obj=>#<TestClass1:0x000000013740a0 @message="test", @_init_arguments={:params=>["test"], :params_types=>[[:req, :message]]}, @_variable_names={10199420=>"message"}>}}
    assert_equal @message, @fixture.call_block( &b)

    # TestClass1#something_is_wrong  should return StandardError
    assert_raises(StandardError) { @fixture.something_is_wrong }

    # TestClass1#just_returns_true  should return true
    assert @fixture.just_returns_true
  end
end

class TestClass1Scenario3 < TestClass1Test
  def setup
    @fixture = TestClass1.new('Hello')
  end

  def test_current_expectation
    another_object = TestClass1.new('test')

    # TestClass1#return_self when passed message = #<TestClass1:0x000000013740a0> should return #<TestClass1:0x000000013740a0>
    assert_equal another_object, @fixture.return_self(another_object)
  end
end

class TestClass1Scenario4 < TestClass1Test
  def setup
    @message = TestClass1.new('test')
    @fixture = TestClass1.new(@message)
  end

  def test_current_expectation
    # TestClass1#message  should return #<TestClass1:0x000000013740a0>
    assert_equal @message, @fixture.message
  end
end

