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
      context = Pretentious::Context.new(variable_map)
      declarations, _dependencies = @deconstructor.generate_declarations(context, [], fixture)

      [context, declarations]
    end

    protected

    def declare_dependencies(context, args, level)
      deconstructor = Pretentious::Deconstructor.new

      args = remove_primitives(args, context.variable_map)
      deconstructor.deconstruct_to_ruby(context, level * @_indentation.length, *args)
    end

    def remove_primitives(args, let_lookup)
      args.select { |a| let_lookup.include?(a.object_id) || !Pretentious::Deconstructor.primitive?(a) }
    end

    def params_generator(context, args)
      params = []
      args.each do |arg|
        if context.variable_map[arg.object_id]
          params << context.pick_name(arg.object_id)
        else
          params << context.value_of(arg)
        end
      end
      params.join(', ')
    end

    def desc_params(block)
      params = []
      args = block[:params]
      names = block[:names]
      # puts args.inspect
      return '' if args.nil?

      args.each_with_index do |arg, index|
        param_name = names[index][1].to_s
        arg_value = (arg.is_a? String) ? "#{arg.dump}" : "#{arg}"
        if param_name.empty?
          params << "#{arg_value}"
        else
          params << "#{param_name} = #{arg_value}"
        end
      end
      params.join(' ,')
    end

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
