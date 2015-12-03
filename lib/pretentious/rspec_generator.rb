module Pretentious
  class RspecGenerator < Pretentious::GeneratorBase
    def begin_spec(test_class)
      buffer('# This file was automatically generated by the pretentious gem')
      buffer("require 'spec_helper'")
      whitespace
      buffer("RSpec.describe #{test_class.name} do")
      whitespace
    end

    def end_spec
      buffer('end')
    end

    def output
      @output_buffer
    end

    def generate(test_instance, instance_count)
      global_variable_declaration = {}
      if test_instance.is_a? Class
        # class methods
        class_method_calls = test_instance.method_calls_by_method
        buffer(generate_specs("#{test_instance.test_class.name}::", test_instance.test_class.name,
                       class_method_calls, test_instance.let_variables, global_variable_declaration, {}))
      else
        buffer("context 'Scenario #{instance_count}' do", 1)

        buffer('before do', 2)

        top_declarations, declarations, variable_map, _global_declared_names = setup_fixture(test_instance)
        method_calls = test_instance.method_calls_by_method
        specs_buffer = generate_specs("#{test_instance.test_class.name}#", "@fixture", method_calls, variable_map,
                                      global_variable_declaration, top_declarations)
        buffer_inline(@deconstructor.build_output(3 * @_indentation.length, variable_map, declarations, global_variable_declaration, {}))
        buffer('end', 2)
        whitespace
        buffer(specs_buffer)
        buffer('end', 1)
        whitespace
      end
    end

    private

    def proc_function_generator(block, method)
      "func_#{method}(#{Pretentious::Deconstructor.block_params_generator(block)})"
    end

    def get_block_source(block, let_variables, declared,indentation)
      " &#{Pretentious::Deconstructor.pick_name(let_variables, block.target_proc.object_id, declared)}"
    end

    def generate_expectation(fixture, method, let_variables, declarations, params, block, result)
      output = ''
      block_source = if !block.nil? && block.is_a?(Pretentious::RecordedProc)
                      get_block_source(block, let_variables, declarations, @_indentation * 3)
                     else
                       ''
      end

      statement = if params.size > 0
                    "#{fixture}.#{method}(#{params_generator(params, let_variables, declarations)})#{block_source}"
                  else
                    stmt = []
                    stmt << "#{fixture}.#{method}"
                    stmt << "#{block_source}" unless block_source.empty?
                    stmt.join(' ')
                  end

      if result.is_a? Exception
        buffer_to_string(output, "expect { #{statement} }.to #{pick_matcher(result, let_variables, declarations)}",3)
      else
        buffer_to_string(output, "expect(#{statement}).to #{pick_matcher(result, let_variables, declarations)}",3)
      end
      output
    end

    def generate_specs(context_prefix, fixture, method_calls, let_variables, declaration, previous_declaration)
      output = ''
      buffer_to_string(output, "it 'should pass current expectations' do", 2)
      # collect all params
      params_collection = []
      mocks_collection = {}
      method_call_collection = []

      method_calls.each_key do |k|
        info_blocks_arr = method_calls[k]
        info_blocks_arr.each do |block|
          method_call_collection << block
          params_collection |= block[:params]
          if !Pretentious::Deconstructor.primitive?(block[:result]) && !block[:result].kind_of?(Exception)
            params_collection << block[:result]
          end

          params_collection << block[:block] unless block[:block].nil?

          next unless block[:context]
          block[:context][:calls].each do |mock_block|
            k = "#{mock_block[:class]}_#{mock_block[:method]}"

            mocks_collection[k] = [] if mocks_collection[k].nil?

            mocks_collection[k] << mock_block
            params_collection << mock_block[:result]
          end
        end
      end

      if params_collection.size > 0
        deps = declare_dependencies(params_collection, let_variables,
                                    3 * @_indentation.length, declaration,
                                    [], previous_declaration)
        buffer_to_string(output, deps) if deps != ''
      end

      if mocks_collection.keys.size > 0
        buffer_to_string(output, generate_rspec_stub(mocks_collection,
                                                     let_variables,
                                                     3 * @_indentation.length,
                                                     declaration))
      end

      method_calls.each_key do |k|
        info_blocks_arr = method_calls[k]

        info_blocks_arr.each do |block|
          params_desc_str =  if block[:params].size > 0
                               "when passed #{desc_params(block)}"
                             else
                               ''
                             end

          buffer_to_string(output, "# #{context_prefix}#{k} #{params_desc_str} should return #{block[:result]}", 3)

          buffer_inline_to_string(output, generate_expectation(fixture, k, let_variables, declaration, block[:params], block[:block], block[:result]))
        end
      end

      buffer_to_string(output, 'end', 2)
      output
    end

    def generate_rspec_stub(mocks_collection, let_variables, indentation_level , declaration)
      indentation = ''

      indentation_level.times { indentation << ' ' }
      str = ''
      mocks_collection.each do |_k, values|
        vals = values.collect { |v| Pretentious.value_ize(v[:result], let_variables, declaration) }

        # check if all vals are the same and just use one
        vals = [vals[0]] if vals.uniq.size == 1

        str << "#{indentation}allow_any_instance_of(#{values[0][:class]}).to receive(:#{values[0][:method]}).and_return(#{vals.join(', ')})\n"
      end
      str
    end

    def pick_matcher(result, let_variables, declared_names)
      if result.is_a? TrueClass
        'be true'
      elsif result.is_a? FalseClass
        'be false'
      elsif result.nil?
        'be_nil'
      elsif result.is_a? Exception
        'raise_error'
      elsif let_variables && let_variables[result.object_id]
        "eq(#{Pretentious.value_ize(result, let_variables, declared_names)})"
      else
        "eq(#{Pretentious.value_ize(result, nil, nil)})"
      end
    end

    def desc_params(block)
      params = []
      args = block[:params]
      names = block[:names]
      n = 0

      return '' if args.nil?

      args.each do |arg|
        param_name = names[n][1].to_s
        arg_value = (arg.is_a? String) ? "#{arg.dump}" : "#{arg.to_s}"
        if param_name.empty?
          params << "#{arg_value}"
        else
          params << "#{param_name} = #{arg_value}"
        end

        n += 1
      end
      params.join(' ,')
    end

    def declare_dependencies(args, variable_map, level, declarations, method_call_collection, top_level_declaration = {})
      deconstructor = Pretentious::Deconstructor.new

      args = remove_primitives(args, variable_map)
      deconstructor.deconstruct_to_ruby(level, variable_map, declarations,
                                        top_level_declaration,
                                        method_call_collection, *args)
    end

    def remove_primitives(args, let_lookup)
      args.select { |a| let_lookup.include?(a.object_id) || !Pretentious::Deconstructor.primitive?(a) }
    end

    def params_generator(args, let_variables, declared_names)
      params = []
      args.each do |arg|
        if !let_variables.nil? && let_variables[arg.object_id]
          params << Pretentious::Deconstructor.pick_name(let_variables, arg.object_id, declared_names)
        else
          params << Pretentious.value_ize(arg, let_variables, declared_names)
        end
      end
      params.join(', ')
    end

    def self.location(output_folder)
      output_folder.nil? ? 'spec' : File.join(output_folder, 'spec')
    end

    def self.naming(output_folder, klass)
      klass_name_parts = klass.name.split('::')
      last_part = klass_name_parts.pop
      File.join(output_folder, "#{Pretentious::DdtUtils.to_underscore(last_part)}_spec.rb")
    end

    def self.helper(output_folder)
      filename = File.join(output_folder, 'spec_helper.rb')
      unless File.exist?(filename)
        File.open(filename, 'w') { |f| f.write('# Place your requires here') }
        puts "#{filename}"
      end
    end
  end
end
