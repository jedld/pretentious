require 'ddt'

class Fibonacci

  def fib(n)
    return 0 if (n == 0)
    return 1 if (n == 1)
    return 1 if (n == 2)
    return fib(n - 1) + fib(n - 2)
  end

end


fib = Fibonacci.new


(1..10).each do |n|
  puts "n=#{n} #{fib.fib(n)}"
end

 if (fib.fib(1) == 1)
   puts "correct"
 else
   puts "wrong"
 end

result = Ddt::Generator.generate_for(Fibonacci) do |instance|
  instance.fib(1)
end

puts result