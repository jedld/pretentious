$LOAD_PATH << '.'

require 'digest/md5'
require_relative './test_classes.rb'


Pretentious.spec_for(Fibonacci) do


  instance = Fibonacci.new

  (1..5).each do |n|
    instance.fib(n)
  end

  Fibonacci.say_hello

end

Pretentious.spec_for(TestClass1, TestClass2, TestClass3, TestClass4) do

  another_object = TestClass1.new("test")
  test_class_one = TestClass1.new({hello: "world", test: another_object, arr_1: [1,2,3,4,5, another_object],
                                   sub_hash: {yes: true, obj: another_object}})
  test_class_two = TestClass2.new("This is message 2")

  class_to_test = TestClass3.new(test_class_one, test_class_two)
  class_to_test.show_messages

  class_to_test = TestClass3.new(test_class_one, test_class_two)
  class_to_test.show_messages

  class_to_test4 = TestClass4.new {
    another_object.message
  }

  test_class_one.set_block { |message|
    message
  }

  test_class_one.call_block {
    class_to_test4.message
  }

end

Pretentious.spec_for(Digest::MD5) do
  sample = "This is the digest"
  Digest::MD5.hexdigest(sample)
end
