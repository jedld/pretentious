class Ddt::RspecGenerator

  def initialize(options = {})
    @deconstructor = Ddt::Deconstructor.new
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
      buffer(declare_dependencies(args, test_instance.init_let_variables, 3))
      if (args.size > 0)
        buffer("@fixture = #{test_instance.test_class.name}.new(#{params_generator(args, test_instance.init_let_variables)})",3)
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

  def generate_expectation(fixture, method, let_variables, params, result)
    if params.size > 0

      buffer("expect(#{fixture}.#{method.to_s}(#{params_generator(params, let_variables)})).to #{pick_matcher(result)}",3)
    else
      buffer("expect(#{fixture}.#{method.to_s}).to #{pick_matcher(result)}",3)
    end
  end

  def generate_specs(context_prefix, fixture, method_calls, let_variables)
    buffer("it 'should pass current expectations' do",2)
    whitespace
    method_calls.each_key do |k|
      info_blocks_arr = method_calls[k]

      #collect all params
      params_collection = []

      info_blocks_arr.each do |block|
        params_collection = params_collection | block[:params]
      end

      buffer(declare_dependencies(params_collection, let_variables, 3))

      info_blocks_arr.each do |block|

        buffer("# #{context_prefix}#{k} when passed #{desc_params(block)} should return #{block[:result]}", 3)
        generate_expectation(fixture, k, let_variables, block[:params], block[:result])

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
     "be true"
    elsif result.is_a? FalseClass
      "be false"
    else
      "eq #{Ddt::value_ize(result)}"
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

  def declare_dependencies(args, variable_map, level)
    deconstructor = Ddt::Deconstructor.new


    let_lookup = {}

    unless (variable_map.nil?)
      variable_map.each { |k,v|
        let_lookup[v.object_id] = k
      }
    end

    args = remove_primitives(args, let_lookup)
    deconstructor.deconstruct_to_ruby(level, let_lookup, *args)
  end

  def remove_primitives(args, let_lookup)
    args.select { |a| let_lookup.include?(a.object_id) || !Ddt::Deconstructor.is_primitive?(a) }
  end

  def params_generator(args, let_variables)
    params = []
    deconstruct = nil
    let_lookup = {}
    let_variables.each.collect { |k,v|
        let_lookup[v.object_id] = k
    }
    args.each do |arg|
      unless (let_lookup[arg.object_id].nil?)
        params <<  let_lookup[arg.object_id].to_s
      else
        params << Ddt::value_ize(arg)
      end

    end
    params.join(", ")
  end

end