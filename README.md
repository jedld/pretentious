# Ruby::Pretentious

Do you have a pretentious boss or dev lead that pushes you to embrace bdd/tdd but for reasons hate it or them?
here is a gem to deal with that. Now you CAN write code first and then GENERATE tests later!! Yes you heard that
right! This gem allows you to write your code first and then automatically generate tests using the code
you've written!

On a serious note, this gem allows you to generate tests template much better than those generated by default
for various frameworks.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pretentious'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pretentious

## Usage

First Create an example file (etc. example.rb) and define the classes that you want to test, if the class is
already defined elsewhere just require them. Below is an example:

```ruby
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
```

Inside a Pretentious.spec_for(...) block. Just write boring code that calls the methods of your class like
how you'd normally use them. Finally Specify the classes that you want to test:

```ruby
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

Pretentious.spec_for(Fibonacci) do


  instance = Fibonacci.new

  (1..10).each do |n|
    instance.fib(n)
  end

  Fibonacci.say_hello

end
```

Save your file and then switch to the terminal to invoke:

    ddtgen example.rb

This will automatically generate rspec tests for Fibonacci under spec of the current working directory.

you can invoke spec at this point, but the tests will fail. Instead you should edit spec/spec_helper.rb and
put the necessary requires and definitions there.

For this example place the following into spec_helper.rb:

```ruby
#inside spec_helper.rb

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
```

You can also try this out with build in libraries like MD5 for example

```ruby
#example.rb

Pretentious.spec_for(Digest::MD5) do
  sample = "This is the digest"
  Digest::MD5.hexdigest(sample)
end
```

You should get something like:

```ruby
require 'spec_helper'

RSpec.describe Digest::MD5 do

    it 'should pass current expectations' do

      sample = "This is the digest"

      # Digest::MD5::hexdigest when passed "This is the digest" should return 9f12248dcddeda976611d192efaaf72a
      expect( Digest::MD5.hexdigest(sample) ).to eq("9f12248dcddeda976611d192efaaf72a")

    end
end
```

Only RSpec is support at this point. But other testing frameworks should be trivial to add support to.

## Limitations

Computers are bad at mind reading (for now) and they don't really know your expectation of "correctness", as such
it assumes your code is correct and can only use equality based matchers. It can also only reliably match
primitive data types and hashs and arrays to degree. More complex expectations are unfortunately left for the human to resolve.

Also do note that it tries its best to determine how your fixtures are created, as well as the types
of your parameters and does so by figuring out the components that your object needs. Failure can happen during this process.

Finally, Limit this gem for test environments only.

## Bugs

This is the first iteration and a lot of broken things could happen

## Contributing

1. Fork it ( https://github.com/jedld/ruby-ddt.git )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
