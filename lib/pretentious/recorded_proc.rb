module Pretentious
  # Sublass of Proc that records whatever was passed to it and whatever it returns
  class RecordedProc < Proc
    attr_reader :target_proc, :return_value

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

    def is_called?
      @called
    end

    def call(*args, &block)
      @called = true
      @args << args
      return_value = @target_proc.call(*args, &block)

      @return_value << return_value unless @return_value.include? return_value
      return_value
    end
  end
end
