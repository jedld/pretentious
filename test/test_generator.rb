require 'pretentious'
require 'digest/md5'
require 'json'

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

end

#examples

results_ddt = Pretentious::Generator.generate_for(Fibonacci) do

  instance = Fibonacci.new

  (1..10).each do |n|
    instance.fib(n)
  end

  Fibonacci.say_hello
end

results_ddt.each_value { |v| puts v}

results_md5 = Pretentious::Generator.generate_for(Digest::MD5) do
  sample = "This is the digest"
  Digest::MD5.hexdigest(sample)
end

results_md5.each_value { |v| puts v}

results_composition = Pretentious::Generator.generate_for(TestClass3, TestClass2, TestClass1) do
  another_object = TestClass1.new("test")
  test_class_one = TestClass1.new({hello: "world", test: another_object, arr_1: [1,2,3,4,5, another_object],
                                  sub_hash: {yes: true, obj: another_object}})
  test_class_two = TestClass2.new("This is message 2")

  class_to_test = TestClass3.new(test_class_one, test_class_two)
  class_to_test.show_messages

  class_to_test = TestClass3.new(test_class_one, test_class_two)
  class_to_test.show_messages

  puts another_object._deconstruct_to_ruby

  begin
    another_object.something_is_wrong
  rescue Exception=>e
  end


end

results_composition.each_value { |v| puts v}