require "ddt/version"
require "ddt/rspec_generator"
require 'binding_of_caller'

module Ddt

  class Generator

    def self.impostor_for(module_space, klass)
      newStandInKlass = Class.new()
      name = klass.name
      module_space.const_set "#{name.split('::').last}Impostor", newStandInKlass

      common_snippet = "
              @_method_calls = @_method_calls || []
              @_method_calls_by_method = @_method_calls_by_method || {}
              @_methods_for_test = @_methods_for_test || []
              @_let_variables = @_let_variables || {}

              caller_context = binding.of_caller(1)
              puts \"local_variables\"
              v_locals = caller_context.eval('local_variables')

              arguments.each do |a|
                v_locals.each { |v|
                  puts \"evaluating \#{a.to_s} => \#{v}\"
                  variable_value = caller_context.eval(\"\#{v.to_s}\")
                  if (a.object_id == variable_value.object_id)
                    @_let_variables[v] = a
                  end
                }
              end
              info_block = {}
              info_block[:method] = method_sym
              info_block[:params] = arguments
              info_block[:names] = @_instance.method(method_sym).parameters

              if (@_instance.methods.include? method_sym)
                result = @_instance.send(method_sym, *arguments, &block)
              else
                result = @_instance.send(:method_missing, method_sym, *arguments, &block)
              end

              info_block[:result] = result

              @_method_calls << info_block

              if (@_method_calls_by_method[method_sym].nil?)
                @_method_calls_by_method[method_sym] = []
              end

              @_method_calls_by_method[method_sym] << info_block
              result"

      newStandInKlass.class_eval(
          "
        def initialize(*args, &block)
          puts \"new standin class #{klass.name}\"

          @_instance_init = {params: [], block: nil}

          @_instance_init[:params] = args
          @_instance_init[:block] = block

          @_instance = #{klass.name}_ddt.new(*args, &block)

          @_method_calls = []
          @_method_calls_by_method = {}
          @_methods_for_test = []
          @_let_variables = {}

          self.class._add_instances(self)
        end

        def _init_arguments
          @_instance_init
        end

        def test_class
          @_instance.class
        end

        def include_for_tests(method_list = [])
          @_methods_for_test = @_methods_for_test + method_list
        end

        def method_missing(method_sym, *arguments, &block)
          #{common_snippet}
        end

        def let_variables
           @_let_variables
        end

        def method_calls_by_method
          @_method_calls_by_method
        end

        def method_calls
          @_method_calls
        end

        def to_s
          @_instance.to_s
        end

        def ==(other)
          @_instance==other
        end

        def kind_of?(klass)
          @_instance.kind_of? klass
        end

        def methods
          @_instance.methods + [:method_calls]
        end

        def freeze
          @_instance.freeze
        end

        def hash
          @instance.hash
        end

        def inspect
          @_instance.inspect
        end

        def is_a?(something)
          @_instance.is_a? something
        end



        class << self

            def test_class
              #{klass.name}
            end

            def method_missing(method_sym, *arguments, &block)
              puts \"method \#{method_sym.to_s}\"
              _add_instances(self)
              @_instance = #{klass.name}_ddt
              #{common_snippet}
            end

            def let_variables
               @_let_variables
            end

            def method_calls_by_method
              @_method_calls_by_method
            end

            def method_calls
              @_method_calls
            end

            def _add_instances(instance)
              @_instances = @_instances || []
              @_instances << instance unless @_instances.include? instance
            end

            def _instances
              @_instances
            end

        end
      ")

      newStandInKlass
    end

    def self.generate_for(klass_or_instance, options = {}, &block)

      klass = klass_or_instance.class == Class ? klass_or_instance : klass_or_instance.class
      test_generator = Ddt::RspecGenerator.new



      klass_name_parts = klass.name.split("::")
      last_part = klass_name_parts.pop

      module_space = Object

      if (klass_name_parts.size > 0)
        klass_name_parts.each do |part|
          module_space = module_space.const_get(part)
        end
      end

      newStandInKlass = impostor_for module_space, klass

      module_space.send(:remove_const,last_part.to_sym)
      module_space.const_set("#{last_part}_ddt", klass)
      module_space.const_set("#{last_part}", newStandInKlass)

      watch_new_instances

      block.call

      unwatch_new_instances

      module_space.send(:remove_const,"#{last_part}Impostor".to_sym)
      module_space.send(:remove_const,"#{last_part}".to_sym)
      module_space.const_set(last_part, klass)
      module_space.send(:remove_const,"#{last_part}_ddt".to_sym)

      test_generator.begin_spec(klass)
      newStandInKlass._instances.each do |instance|
         test_generator.generate(instance)
      end
      test_generator.end_spec
      test_generator.output
    end

    def self.watch_new_instances
      Object.class_eval do
        def _get_init_arguments
          @_init_arguments
        end

        def _set_init_arguments(*args, &block)
          @_init_arguments = @_init_arguments || {}
          @_init_arguments[:args]  = args
          @_init_arguments[:block] = block
        end
      end

      Class.class_eval do
        alias_method :_ddt_old_new, :new

        def new(*args, &block)
          instance = _ddt_old_new(*args, &block)
          instance._set_init_arguments(*args, &block)
          instance
        end
      end
    end

    def self.unwatch_new_instances
      Class.class_eval do
        remove_method :new
        alias_method :new, :_ddt_old_new
      end
      Object.class_eval do
        remove_method :_get_init_arguments, :_set_init_arguments
      end
    end

  end

end