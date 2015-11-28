require 'digest/md5'

class Fibonacci

  def fib(n)
    return 0 if (n == 0)
    return 1 if (n == 1)
    return 1 if (n == 2)
    return fib(n - 1) + fib(n - 2)
  end

  def self.say_hello
    "hello"
  end

end

class Meme
  def i_can_has_cheezburger?
    "OHAI!"
  end

  def will_it_blend?
    "YES!"
  end
end

class TestClass1

  def initialize(message)
    @message = message
  end

  def set_block(&block)
    @block = block
  end

  def call_block
    @block.call(@message)
  end

  def message
    @message
  end

  def just_returns_true
    true
  end

  def print_message
    puts @message
  end

  def invoke_class
    @message.print_message
  end

  def something_is_wrong
    raise StandardError.new
  end
end


class TestClass2
  def initialize(message)
    @message = {message: message}
  end

  def print_message
    puts @message[:message]
  end
end

class TestClass3

  def initialize(testclass1, testclass2)
    @class1 = testclass1
    @class2 = testclass2
  end

  def show_messages
    @class1.print_message
    @class2.print_message
    "awesome!!!"
  end

  def swap_hash(j, &block)
    h = []
    j.each do |k,v|
      h << block.call(v,k)
    end
    h
  end

  def check_proc
    @class2.call(1,2,3)
  end

end

class TestClass4

  def initialize(&block)
    @message = block.call
  end

  def message
    @message
  end

  def to_s
    @message
  end

end

class TestMockSubClass

  def initialize
    @val = 1
  end

  def test_method
    "a return string"
  end

  def increment_val
    @val += 1
    @val
  end

  def return_hash(message)
    {val: @val, str: "hello world", message: message}
  end
end

class TestClassForMocks

  def initialize
    @test_class2 = TestMockSubClass.new
  end

  def message(params1)
    @params1 = params1
  end

  def method_with_assign=(params2)
    @params2 = "#{params2}!"
    @params2
  end

  def method_with_usage
    @test_class2.test_method
  end

  def method_with_usage2
    results = []
    results << @test_class2.increment_val
    results << @test_class2.increment_val
    results << @test_class2.increment_val
    results << @test_class2.increment_val
    results
  end

  def method_with_usage4
    @test_class2.test_method
    @test_class2.test_method
    @test_class2.test_method
  end

  def method_with_usage3(message)
    @test_class2.return_hash(message)
  end

end

class ClassUsedByTestClass

  def stubbed_method
    "Hello Glorious world"
  end
end

class AnotherClassUsedByTestClass

  def get_message
    "HI THERE!!!!"
  end
end

class TestClassForAutoStub

  def initialize
    @class_to_be_used = ClassUsedByTestClass.new
    @class_to_be_used2 = AnotherClassUsedByTestClass.new
  end

  def method_that_uses_the_class_to_stub
    @class_to_be_used
    @class_to_be_used2
    return_values = []
    return_values << @class_to_be_used.stubbed_method
    return_values << @class_to_be_used2.get_message
    return_values
  end

end