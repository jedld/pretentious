class TestClass1

  def initialize(message)
    @message = message
  end

  def print_message
    puts @message
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


Ddt.spec_for(TestClass3) do

  another_object = TestClass1.new("test")
  test_class_one = TestClass1.new({hello: "world", test: another_object, arr_1: [1,2,3,4,5, another_object],
                                   sub_hash: {yes: true, obj: another_object}})
  test_class_two = TestClass2.new("This is message 2")

  class_to_test = TestClass3.new(test_class_one, test_class_two)
  class_to_test.show_messages

  class_to_test = TestClass3.new(test_class_one, test_class_two)
  class_to_test.show_messages


end