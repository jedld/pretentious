class Pretentious::RspecGenerator

  def initialize(options = {})
    @deconstructor = Pretentious::Deconstructor.new
    indentation_count = options[:indentation] || 2
    @output_buffer = ""
    @_indentation = ""
    indentation_count.times do
      @_indentation << " "
    end
  end

  def indentation(level)
    buffer = ""
    level.times do
      buffer << @_indentation
    end
    buffer
  end

  def buffer(line, level = 0)
    @output_buffer << "#{indentation(level)}#{line}\n"
  end

  def whitespace(level = 0)
    @output_buffer << "#{indentation(level)}\n"
  end

  def begin_spec(test_class)
    buffer("require 'spec_helper'")
    whitespace
    buffer("RSpec.describe #{test_class.name} do")
    whitespace
  end

  def end_spec
    buffer("end")
  end

  def output
    @output_buffer
  end

  def generate(test_instance, instance_count)
    if (test_instance.is_a? Class)
      #class methods
      class_method_calls = test_instance.method_calls_by_method
      generate_specs("#{test_instance.test_class.name}::",test_instance.test_class.name, class_method_calls, test_instance.let_variables)
    else
      buffer("context 'Scenario #{instance_count}' do",1)

      buffer("before do",2)
      whitespace
      args = test_instance._init_arguments[:params]
      declarations = {}
      buffer(declare_dependencies(args, test_instance.init_let_variables, 3 * @_indentation.length, declarations))
      if (args.size > 0)
        buffer("@fixture = #{test_instance.test_class.name}.new(#{params_generator(args, test_instance.init_let_variables, declarations)})",3)
      else
        buffer("@fixture = #{test_instance.test_class.name}.new",3)
      end
      whitespace
      buffer("end",2)
      whitespace

      method_calls = test_instance.method_calls_by_method

      generate_specs("#{test_instance.test_class.name}#","@fixture",method_calls, test_instance.let_variables)

      buffer('end',1)
      whitespace
    end

  end

  private

  def generate_expectation(fixture, method, let_variables, declarations, params, result)
    statement = if params.size > 0
      "#{fixture}.#{method.to_s}(#{params_generator(params, let_variables, declarations)})"
    else
      "#{fixture}.#{method.to_s}"
    end

    if (result.kind_of? Exception)
      buffer("expect { #{statement} }.to #{pick_matcher(result)}",3)
    else
      buffer("expect( #{statement} ).to #{pick_matcher(result)}",3)
    end
  end

  def generate_specs(context_prefix, fixture, method_calls, let_variables)
    buffer("it 'should pass current expectations' do",2)
    whitespace
    declaration = {}
    #collect all params
    params_collection = []

    method_calls.each_key do |k|
      info_blocks_arr = method_calls[k]
      info_blocks_arr.each do |block|
        params_collection = params_collection | block[:params]
        if (!Pretentious::Deconstructor.is_primitive?(block[:result]) && !block[:result].kind_of?(Exception))
          params_collection << block[:result]
        end
      end
    end

    buffer(declare_dependencies(params_collection, let_variables, 3 * @_indentation.length, declaration))

    method_calls.each_key do |k|
      info_blocks_arr = method_calls[k]

      info_blocks_arr.each do |block|

        buffer("# #{context_prefix}#{k} when passed #{desc_params(block)} should return #{block[:result]}", 3)
        generate_expectation(fixture, k, let_variables, declaration, block[:params], block[:result])

        whitespace
      end


    end
    buffer("end",2)
  end

  #def generate_specs(context_prefix, fixture, method_calls, let_variables)
  #  method_calls.each_key do |k|
  #    info_blocks_arr = method_calls[k]
  #
  #    buffer("context \"#{context_prefix}#{k}\" do", 1)
  #
  #    whitespace
  #    info_blocks_arr.each do |block|
  #      buffer("it '#{desc_params(block)} returns #{block[:result]}' do",2)
  #      whitespace
  #      if block[:params].size > 0
  #        buffer(declare_dependencies(block[:params], let_variables, 3))
  #        buffer("expect(#{fixture}.#{k.to_s}(#{params_generator(block[:params], let_variables)})).to #{pick_matcher(block[:result])}",3)
  #      else
  #        buffer("expect(#{fixture}.#{k.to_s}).to #{pick_matcher(block[:result])}",3)
  #      end
  #      whitespace
  #      buffer("end",2)
  #      whitespace
  #    end
  #
  #    buffer("end", 1)
  #    whitespace
  #  end
  #end

  def pick_matcher(result)
    if result.is_a? TrueClass
     'be true'
    elsif result.is_a? FalseClass
      'be false'
    elsif result.nil?
      'be_nil'
    elsif result.kind_of? Exception
      'raise_error'
    else
      "eq(#{Pretentious::value_ize(result, nil, nil)})"
    end
  end



  def desc_params(block)
    params = []
    args = block[:params]
    names = block[:names]
    n = 0
    #puts args.inspect
    return "" if args.nil?

    args.each do |arg|
      param_name = names[n][1].to_s
      arg_value = (arg.is_a? String) ? "#{arg.dump}" : "#{arg.to_s}"
      if (param_name.empty?)
        params << "#{arg_value}"
      else
        params << "#{param_name} = #{arg_value}"
      end

      n+=1
    end
    params.join(" ,")
  end

  def declare_dependencies(args, variable_map, level, declarations)
    deconstructor = Pretentious::Deconstructor.new

    args = remove_primitives(args, variable_map)
    deconstructor.deconstruct_to_ruby(level, variable_map, declarations, *args)
  end

  def remove_primitives(args, let_lookup)
    args.select { |a| let_lookup.include?(a.object_id) || !Pretentious::Deconstructor.is_primitive?(a) }
  end

  def params_generator(args, let_variables, declared_names)
    params = []
    args.each do |arg|
      if (!let_variables.nil? && let_variables[arg.object_id])
        params <<  Pretentious::Deconstructor.pick_name(let_variables, arg.object_id, declared_names)
      else
        params << Pretentious::value_ize(arg, let_variables, declared_names)
      end

    end
    params.join(", ")
  end

end