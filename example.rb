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

[:spec_for, :minitest_for].each do |method|
  Pretentious.send(method, TestClass1, TestClass2, TestClass3, TestClass4) do
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

    begin
      test_class_one.something_is_wrong
    rescue Exception=>e
    end

    test_class_one.just_returns_true
  end
end

Pretentious.spec_for(Digest::MD5) do
  sample = "This is the digest"
  Digest::MD5.hexdigest(sample)
end

[:spec_for, :minitest_for].each do |m|
  Pretentious.send(m, TestClassForMocks._stub(TestMockSubClass)) do
    instance = TestClassForMocks.new
    instance.method_with_assign = "test"
    instance.method_with_usage
    instance.method_with_usage2
    instance.method_with_usage4

    instance2 = TestClassForMocks.new
    instance2.method_with_usage3("a message")
  end
end

Pretentious.spec_for(TestClassForAutoStub._stub(ClassUsedByTestClass)) do
  instance = TestClassForAutoStub.new
  instance.method_that_uses_the_class_to_stub
end

Pretentious.spec_for(TestClassForAutoStub._stub(ClassUsedByTestClass, AnotherClassUsedByTestClass)) do
  instance = TestClassForAutoStub.new
  instance.method_that_uses_the_class_to_stub
end

Pretentious.minitest_for(Meme) do
  meme = Meme.new
  meme.i_can_has_cheezburger?
  meme.will_it_blend?
end