module Pretentious
  # base class for spec generators
  class GeneratorBase
    def initialize(options = {})
      @deconstructor = Pretentious::Deconstructor.new
      indentation_count = options[:indentation] || 2
      @output_buffer = ''
      @_indentation = ''
      indentation_count.times do
        @_indentation << ' '
      end
    end

    def buffer(line, level = 0)
      @output_buffer << "#{indentation(level)}#{line}\n"
    end

    def buffer_to_string(buffer, line, level = 0)
      buffer << "#{indentation(level)}#{line}\n"
    end

    def buffer_inline_to_string(buffer, line, level = 0)
      buffer << "#{indentation(level)}#{line}"
    end

    def buffer_inline(line, level = 0)
      @output_buffer << "#{indentation(level)}#{line}"
    end

    def setup_fixture(fixture)
      variable_map = fixture.let_variables.merge(fixture.object_id => '@fixture')
      top_declarations = {}
      global_declared_names = {}

      declarations, _dependencies = @deconstructor.generate_declarations(variable_map, [], fixture)

      declarations[:declaration].each do |d|
        if (d[:used_by] != :inline)
          top_declarations[d[:id]] = Pretentious::Deconstructor.pick_name(variable_map, d[:id], global_declared_names)
        end
      end

      [top_declarations, declarations, variable_map, global_declared_names]
    end

    protected

    def indentation(level)
      buffer = ''
      level.times do
        buffer << @_indentation
      end
      buffer
    end

    def whitespace(level = 0)
      @output_buffer << "#{indentation(level)}\n"
    end
  end
end
