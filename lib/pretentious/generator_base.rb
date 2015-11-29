module Pretentious
  class GeneratorBase

    def buffer(line, level = 0)
      @output_buffer << "#{indentation(level)}#{line}\n"
    end

    def buffer_inline(line, level = 0)
      @output_buffer << "#{indentation(level)}#{line}"
    end

  end
end