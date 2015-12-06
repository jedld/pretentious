module Pretentious
  # Generator that outputs minitest specs
  class MinitestGenerator < Pretentious::GeneratorBase
    def begin_spec(test_class)
      @test_class = test_class
      buffer('# This file was automatically generated by the pretentious gem')
      buffer("require 'minitest_helper'")
      buffer('require "minitest/autorun"')
      whitespace
      buffer("class #{test_class.name}Test < Minitest::Test")
      buffer('end')
      whitespace
    end

    def end_spec
    end

    def output
      @output_buffer
    end

    def generate(test_instance, instance_count)
      if test_instance.is_a? Class
        buffer("class #{test_instance.test_class.name}Scenario#{instance_count} < #{@test_class.name}Test", 0)

        # class methods
        class_method_calls = test_instance.method_calls_by_method
        context = Pretentious::Context.new(test_instance.let_variables)
        buffer(generate_specs(context, "#{test_instance.test_class.name}::",
                              test_instance.test_class.name, class_method_calls))

        buffer('end', 0)
      else
        buffer("class #{test_instance.test_class.name}Scenario#{instance_count} < #{@test_class.name}Test", 0)

        buffer('def setup', 1)

        context, declarations = setup_fixture(test_instance)

        method_calls = test_instance.method_calls_by_method
        specs_buffer = generate_specs(context.subcontext(declarations[:declaration]), "#{test_instance.test_class.name}#",
                                      '@fixture', method_calls)
        context.declared_names = {}
        buffer_inline(@deconstructor.build_output(context, 2 * @_indentation.length, declarations))
        buffer('end', 1)
        whitespace

        buffer_inline(specs_buffer)

        buffer('end', 0)
        whitespace
      end
    end

    private

    def proc_function_generator(block, method)
      "func_#{method}(#{Pretentious::Deconstructor.block_params_generator(block)})"
    end

    def get_block_source(context, block)
      " &#{context.pick_name(block.target_proc.object_id)}"
    end

    def generate_expectation(context, fixture, method, params, block, result)
      str = ''
      block_source = if !block.nil? && block.is_a?(Pretentious::RecordedProc)
                       get_block_source(context, block)
                     else
                       ''
                     end

      statement = if params.size > 0
                    "#{fixture}.#{method}(#{params_generator(context, params)})#{block_source}"
                  else
                    stmt = []
                    m_stmt = "#{fixture}.#{method}"
                    m_stmt << "(#{block_source})" unless block_source.empty?
                    stmt << m_stmt
                    stmt.join(' ')
                  end

      if result.is_a? Exception
        str << pick_matcher(context, statement, result)
      else
        str << pick_matcher(context, statement, result)
      end
      str
    end

    def generate_specs(context, context_prefix, fixture, method_calls)
      output = ''
      buffer_to_string(output, 'def test_current_expectation', 1)
      # collect all params
      params_collection = []
      mocks_collection = {}

      method_calls.each_key do |k|
        info_blocks_arr = method_calls[k]
        info_blocks_arr.each do |block|
          params_collection |= block[:params]
          if !Pretentious::Deconstructor.primitive?(block[:result]) && !block[:result].is_a?(Exception)
            params_collection << block[:result]
          end

          params_collection << block[:block] unless block[:block].nil?

          block[:context][:calls].each do |mock_block|
            k = "#{mock_block[:class]}_#{mock_block[:method]}"

            mocks_collection[k] = [] if mocks_collection[k].nil?

            mocks_collection[k] << mock_block
            params_collection << mock_block[:result]
          end if block[:context]
        end
      end

      if params_collection.size > 0
        deps = declare_dependencies(context, params_collection, 2)
        buffer_to_string(output, deps) if deps.strip != ''
      end

      if mocks_collection.keys.size > 0
        minitest_stub = generate_minitest_stub(context, mocks_collection, 2) do |indentation|
          generate_test_scenarios(context, fixture, method_calls, context_prefix, indentation)
        end
        buffer_to_string(output, minitest_stub, 0)
      else
        buffer_inline_to_string(output, generate_test_scenarios(context, fixture, method_calls, context_prefix, 2), 0)
      end

      buffer_to_string(output, 'end', 1)
      output
    end

    def generate_test_scenarios(context, fixture, method_calls, context_prefix, indentation_level)
      expectations = []
      indentation = ''
      indentation_level.times { indentation << @_indentation }
      method_calls.each_key do |k|
        str = ''
        info_blocks_arr = method_calls[k]

        info_blocks_arr.each do |block|
          params_desc_str =  if block[:params].size > 0
                               "when passed #{desc_params(block)}"
                             else
                               ''
                             end

          str << "#{indentation}# #{context_prefix}#{k} #{params_desc_str} should return #{block[:result]}\n"
          str << "#{indentation}#{generate_expectation(context, fixture, k, block[:params], block[:block], block[:result])}\n\n"
          expectations << str
        end
      end
      expectations.join("\n")
    end

    def generate_minitest_stub(context, mocks_collection, indentation_level, &block)
      str = ''
      current_indentation = indentation_level

      mocks_collection.each do |_k, values|
        indentation = ''
        current_indentation.times { indentation << @_indentation }
        vals = values.collect { |v| context.value_of(v[:result]) }
        str << "#{indentation}#{values[0][:class]}.stub_any_instance(:#{values[0][:method]}, #{vals[0]}) do\n"
        current_indentation += 1
      end

      str << block.call(current_indentation)

      current_indentation -= 1

      mocks_collection.each do
        indentation = ''
        current_indentation.times { indentation << @_indentation }
        str << "#{indentation}end\n"
        current_indentation -= 1
      end
      str
    end

    def pick_matcher(context, statement, result)
      if result.is_a? TrueClass
        "assert #{statement}"
      elsif result.is_a? FalseClass
        "refute #{statement}"
      elsif result.nil?
        "assert_nil #{statement}"
      elsif result.is_a? Exception
        "assert_raises(#{result.class}) { #{statement} }"
      elsif context.variable_map[result.object_id]
        "assert_equal #{context.value_of(result)}, #{statement}"
      else
        "assert_equal #{Pretentious.value_ize(Pretentious::Context.new, result)}, #{statement}"
      end
    end

    def self.location(output_folder)
      output_folder.nil? ? 'test' : File.join(output_folder, 'test')
    end

    def self.naming(output_folder, klass)
      klass_name_parts = klass.name.split('::')
      last_part = klass_name_parts.pop
      File.join(output_folder, "test_#{Pretentious::DdtUtils.to_underscore(last_part)}.rb")
    end

    def self.helper(output_folder)
      filename = File.join(output_folder, 'minitest_helper.rb')
      unless File.exist?(filename)
        File.open(filename, 'w') do |f|
          f.write("# Place your requires here\n")
          f.write("require 'minitest/stub_any_instance'\n")
        end
        puts "#{filename}"
      end
    end
  end
end
