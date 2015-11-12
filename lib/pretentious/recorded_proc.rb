module Pretentious

  class RecordedProc < Proc

    def initialize(target_proc, is_given_block = false)
      @target_proc = target_proc
      @return_value = []
      @args = []
      @given_block = is_given_block
      @called = false
    end

    def given_block?
      @given_block
    end

    def target_proc
      @target_proc
    end

    def return_value
      @return_value
    end

    def is_called?
      @called
    end

    def call(*args, &block)
      @called = true
      @args << args
      return_value = @target_proc.call(*args, &block)

      unless @return_value.include? return_value
        @return_value << return_value
      end

      return_value
    end

  end

end