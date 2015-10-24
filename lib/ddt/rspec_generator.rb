class Ddt::RspecGenerator

  def initialize(options = {})
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

  def generate(test_instance)
    if (test_instance.is_a? Class)
      #class methods
      class_method_calls = test_instance.method_calls_by_method
      generate_specs("::",test_instance.test_class.name, class_method_calls, test_instance.let_variables)
    else
      buffer("before do",1)
      args = test_instance._init_arguments[:params]
      if (args.size > 0)
        buffer("@fixture = #{test_instance.test_class.name}.new(#{params_generator(args, test_instance.let_variables)})",2)
      else
        buffer("@fixture = #{test_instance.test_class.name}.new",2)
      end
      buffer("end",1)
      whitespace

      method_calls = test_instance.method_calls_by_method

      generate_specs("#","@fixture",method_calls, test_instance.let_variables)
    end

  end

  private

  def generate_specs(context_prefix, fixture, method_calls, let_variables)
    method_calls.each_key do |k|
      info_blocks_arr = method_calls[k]

      buffer("context \"#{context_prefix}#{k}\" do", 1)

      whitespace if let_variables.size > 0
      let_variables.each do |k,v|
        buffer("let(:#{k}) {#{value_ize(v)}}",2)
      end

      whitespace
      info_blocks_arr.each do |block|
        buffer("it '#{desc_params(block)} returns #{block[:result]}' do",2)
        whitespace
        if block[:params].size > 0
          buffer("expect(#{fixture}.#{k.to_s}(#{params_generator(block[:params], let_variables)})).to #{pick_matcher(block[:result])}",3)
        else
          buffer("expect(#{fixture}.#{k.to_s}).to #{pick_matcher(block[:result])}",3)
        end
        whitespace
        buffer("end",2)
        whitespace
      end

      buffer("end", 1)
      whitespace
    end
  end

  def pick_matcher(result)
    if result.is_a? TrueClass
     "be true"
    elsif result.is_a? FalseClass
      "be false"
    else
      "eq #{value_ize(result)}"
    end
  end

  def value_ize(value)
    if (value.kind_of? String)
      "#{value.dump}"
    else
      "#{value.to_s}"
    end
  end

  def desc_params(block)
    params = []
    args = block[:params]
    names = block[:names]
    n = 0
    puts args.inspect
    return "" if args.nil?

    args.each do |arg|
      param_name = names[n][1].to_s
      arg_value = (arg.is_a? String) ? "#{arg.dump}" : "#{arg.to_s}"
      if (param_name.empty?)
        params << "passing #{arg_value}"
      else
        params << "#{param_name} = #{arg_value}"
      end

      n+=1
    end
    params.join(" ,")
  end

  def params_generator(args, let_variables)
    params = []
    let_lookup = {}
    let_variables.each.collect { |k,v|
        let_lookup[v.object_id] = k
    }
    args.each do |arg|
      unless (let_lookup[arg.object_id].nil?)
        params <<  let_lookup[arg.object_id].to_s
      else
        params << value_ize(arg)
      end

    end
    params.join(" ,")
  end

end