class Meme
  def i_can_has_cheezburger?
    "OHAI!"
  end

  def will_it_blend?
    "YES!"
  end
end

meme = Meme.new
meme.i_can_has_cheezburger?
meme.will_it_blend?

class TestClassR1
  SOME_CONSTANT = "CONST"

  def hello
  end
end

class TestClassR2
  def hello_again
    "hi"
  end

  def pass_message(message)
    "#{message} #{TestClassR1::SOME_CONSTANT}"
  end
end

[:spec_for, :minitest_for].each do |method|
  Pretentious.send(method, Digest::MD5) do
    sample = "This is the digest"
    Digest::MD5.hexdigest(sample)
  end
end

test_class1 = TestClassR1.new
test_class1.hello

test_class2 = TestClassR2.new
test_class2.hello_again
test_class2.pass_message("a message")
