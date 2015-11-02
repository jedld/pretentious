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
