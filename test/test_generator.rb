require 'ddt'

class Fibonacci

  def fib(n)
    return 0 if (n == 0)
    return 1 if (n == 1)

  end

end


fib = Fibonacci.new

 if (fib.fib(1) == 1)
   puts "correct"
 else
   puts "wrong"
 end