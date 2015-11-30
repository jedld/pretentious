module Pretentious
  class Generator

    def self.test_generator=(generator)
      @test_generator = generator
    end

    def self.test_generator
      @test_generator || Pretentious::RspecGenerator
    end

    def self.impostor_for(module_space, klass)
      newStandInKlass = Class.new()
      name = klass.name

      #return if already an impostor
      return klass if (klass.respond_to?(:test_class))

      module_space.const_set "#{name.split('::').last}Impostor", newStandInKlass

      newStandInKlass.class_eval("
        def setup_instance(*args, &block)
          @_instance = #{klass.name}_ddt.new(*args, &block)
        end
      ")

      newStandInKlass.class_eval("
        class << self
          def _get_standin_class
            #{newStandInKlass}
          end

          def test_class
            #{klass.name}
          end

          def _current_old_class
            #{klass.name}_ddt
          end
        end
      ")

      newStandInKlass.class_exec do

        def initialize(*args, &block)

          @_instance_init = {object_id: self.object_id, params: [], block: nil}

          self.class.replace_procs_with_recorders(args)

          @_instance_init[:params] = args


          recordedProc = if (block)
                           RecordedProc.new(block, true)
                         else
                           nil
                         end

          @_instance_init[:block] = recordedProc

          setup_instance(*args, &recordedProc)
          param_types = @_instance.method(:initialize).parameters
          @_instance_init[:params_types] = param_types

          @_method_calls = []
          @_method_calls_by_method = {}
          @_methods_for_test = []
          @_let_variables = {}


          @_init_let_variables = {}

          caller_context = binding.of_caller(2)
          v_locals = caller_context.eval('local_variables')

          v_locals.each { |v|
            variable_value = caller_context.eval("#{v.to_s}")
            @_init_let_variables[variable_value.object_id] = v
          }

          args.each_with_index { |a, index|
            @_init_let_variables[a.object_id] = param_types[index][1].to_s if param_types.size == 2
          }

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

        def let_variables
          @_let_variables
        end

        def init_let_variables
          @_init_let_variables
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

        def instance_variable_get(sym)
          @_instance.instance_variable_get(sym)
        end

        def instance_variable_set(sym, val)
          @_instance.instance_variable_get(sym, val)
        end

        class << self

          def replace_procs_with_recorders(args)
            (0..args.size).each do |index|
              if (args[index].kind_of? Proc)
                args[index] = Pretentious::RecordedProc.new(args[index]) {}
              end
            end
          end

          def _set_is_stub
            @_is_stub = true
          end

          def _is_stub?
            @_is_stub = @_is_stub || false
            @_is_stub
          end

          def _add_instances(instance)
            @_instances = @_instances || []
            @_instances << instance unless @_instances.include? instance
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

          def instance_methods
            methods = super
            test_class.instance_methods + methods
          end

          def _call_method(target, method_sym, *arguments, &block)

            klass = _get_standin_class
            caller_context = binding.of_caller(2)

            is_stub = _is_stub?

            target.instance_exec do
              @_method_calls = @_method_calls || []
              @_method_calls_by_method = @_method_calls_by_method || {}
              @_methods_for_test = @_methods_for_test || []
              @_let_variables = @_let_variables || {}

              v_locals = caller_context.eval('local_variables')

              v_locals.each { |v|
                variable_value = caller_context.eval("#{v.to_s}")
                  @_let_variables[variable_value.object_id] = v
                }

                klass.replace_procs_with_recorders(arguments)

                info_block = {}
                info_block[:method] = method_sym
                info_block[:params] = arguments

                recordedProc = if (block)
                            RecordedProc.new(block, true)
                           else
                             nil
                           end
                info_block[:block] = recordedProc

                info_block[:names] = @_instance.method(method_sym).parameters

                begin

                  unless is_stub
                    current_context = { calls: [] }
                    info_block[:context] = current_context

                    Thread.current._push_context(current_context)
                  end

                  if (@_instance.methods.include? method_sym)
                    result = @_instance.send(method_sym, *arguments, &recordedProc)
                  else
                    result = @_instance.send(:method_missing, method_sym, *arguments, &recordedProc)
                  end

                  Thread.current._pop_context unless is_stub

                  # methods that end with = are a special case with return values
                  if method_sym.to_s.end_with? '='
                    info_block[:result] = arguments[0]
                  else
                    info_block[:result] = result
                  end

                rescue Exception=>e
                  info_block[:result] = e
                rescue StandardError=>e
                  info_block[:result] = e
                end

                if is_stub
                  info_block[:class] = test_class
                  Thread.current._all_context.each { |mock_context|
                    mock_context[:calls] << info_block if mock_context
                  }
                end

                @_method_calls << info_block

                if (@_method_calls_by_method[method_sym].nil?)
                  @_method_calls_by_method[method_sym] = []
                end

                @_method_calls_by_method[method_sym] << info_block
                raise e if (e.kind_of? Exception)
                result
            end
          end

        end

      end

      newStandInKlass.class_exec do
        def method_missing(method_sym, *arguments, &block)
          #puts "#{method_sym} #{arguments}"
          self.class._call_method(self, method_sym, *arguments, &block)
        end

        class << self
            def method_missing(method_sym, *arguments, &block)
              #puts "method #{method_sym.to_s}"
              _add_instances(self)
              @_instance = _current_old_class
              _call_method(self, method_sym, *arguments, &block)
            end
        end
      end

      newStandInKlass
    end

    def self.replace_class(klass, stub = false)
      klass_name_parts = klass.name.split('::')
      last_part = klass_name_parts.pop

      module_space = Object

      if (klass_name_parts.size > 0)
        klass_name_parts.each do |part|
          module_space = module_space.const_get(part)
        end
      end

      newStandInKlass = impostor_for module_space, klass
      newStandInKlass._set_is_stub if stub

      module_space.send(:remove_const,last_part.to_sym)
      module_space.const_set("#{last_part}_ddt", klass)
      module_space.const_set("#{last_part}", newStandInKlass)

      [module_space, klass, last_part, newStandInKlass]
    end

    def self.restore_class(module_space, klass, last_part)
      module_space.send(:remove_const,"#{last_part}Impostor".to_sym)
      module_space.send(:remove_const,"#{last_part}".to_sym)
      module_space.const_set(last_part, klass)
      module_space.send(:remove_const,"#{last_part}_ddt".to_sym)
    end

    def self.generate_for(*klasses_or_instances, &block)
      all_results = {}
      klasses = []
      mock_dict = {}

      klasses_or_instances.each { |klass_or_instance|
        klass = klass_or_instance.class == Class ? klass_or_instance : klass_or_instance.class
        klasses << replace_class(klass)

        mock_klasses = []

        klass._get_mock_classes.each do |mock_klass|
          mock_klasses << replace_class(mock_klass , true)
        end unless klass._get_mock_classes.nil?

        mock_dict[klass] = mock_klasses
      }

      watch_new_instances

      block.call

      unwatch_new_instances

      klasses.each { |module_space, klass, last_part, newStandInKlass|

        #restore the previous class
        restore_class module_space, klass, last_part

        mock_dict[klass].each do |_module_space, _klass, _last_part, _newStandInKlass|
          restore_class _module_space, _klass, _last_part
        end

        generator = test_generator.new
        generator.begin_spec(klass)
        num = 1

        newStandInKlass._instances.each do |instance|
          generator.generate(instance, num)
          num+=1
        end unless newStandInKlass._instances.nil?

        generator.end_spec

        result = all_results[klass]
        if result.nil?
          all_results[klass] = []
        end

        all_results[klass] = {output: generator.output, generator: generator.class }

      } unless klasses.nil?

      all_results
    end

    def self.watch_new_instances
      Object.class_eval do
        def _get_init_arguments
          @_init_arguments
        end

        def _set_init_arguments(*args, &block)
          @_init_arguments = @_init_arguments || {}
          @_init_arguments[:params]  = args
          unless (block.nil?)
            @_init_arguments[:block] = RecordedProc.new(block) {}
          end
          @_variable_names = {}

          params = if (self.respond_to? :test_class )
                      test_class.instance_method(:initialize).parameters
                    else
                      method(:initialize).parameters
                   end
          @_init_arguments[:params_types] = params

          args.each_with_index do |arg, index|
            p = params[index]
            if p.size > 1
              @_variable_names[arg.object_id] = p[1].to_s
            end unless p.nil?
          end unless args.nil?

        end

        def _variable_map
          @_variable_names || {}
        end

        def _deconstruct
          Pretentious::Deconstructor.new().deconstruct([], self)
        end

        def _deconstruct_to_ruby(var_name = nil, indentation = 0)
          variable_names = {}

          caller_context = binding.of_caller(1)
          v_locals = caller_context.eval('local_variables')

          v_locals.each { |v|
            variable_value = caller_context.eval("#{v.to_s}")
            if self.object_id == variable_value.object_id
              variable_names[variable_value.object_id] = v
            end
          }

          variable_names = _variable_map.merge({self.object_id => var_name}) unless var_name.nil?
          Pretentious::Deconstructor.new().deconstruct_to_ruby(indentation, variable_names, {}, [], self)
        end

      end

      #make sure it is set only once
      if (!Class.instance_methods.include?(:_ddt_old_new))
        Class.class_eval do
          alias_method :_ddt_old_new, :new

          def new(*args, &block)
            instance = _ddt_old_new(*args, &block)
            instance._set_init_arguments(*args, &block)
            instance
          end

        end
      end

    end

    def self.clean_watches
      unwatch_new_instances
    end

    def self.unwatch_new_instances
      if (Class.respond_to?(:_ddt_old_new))
        Class.class_eval do
          remove_method :new
          alias_method :new, :_ddt_old_new
          remove_method :_ddt_old_new
        end
      end
    end

  end

end