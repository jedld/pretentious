require "pretentious/version"
require "pretentious/rspec_generator"
require 'binding_of_caller'
require 'pretentious/deconstructor'

module Pretentious

  def self.spec_for(*klasses, &block)
    @results = @results || {}
    @results.merge!(Pretentious::Generator.generate_for(*klasses, &block))
  end

  def self.clear_results
    @results = {}
  end

  def self.last_results
    @results
  end

  def self.install_watcher
    Pretentious::Generator.watch_new_instances
  end

  def self.uninstall_watcher
    Pretentious::Generator.unwatch_new_instances
  end

  def self.value_ize(value, let_variables, declared_names)
    if (value.kind_of? String)
      "#{value.dump}"
    elsif (value.is_a? Symbol)
      ":#{value.to_s}"
    elsif (value.is_a? Hash)
      Pretentious::Deconstructor.pick_name(let_variables, value.object_id, declared_names)
    elsif (value.is_a? Pretentious::RecordedProc)
      Pretentious::Deconstructor.pick_name(let_variables, value.target_proc.object_id, declared_names)
    elsif (value == nil)
      "nil"
    else
      "#{value.to_s}"
    end
  end

  def self.watch(&block)
    Pretentious::Generator.watch_new_instances
    block.call
    Pretentious::Generator.unwatch_new_instances
  end

  class RecordedProc < Proc

    def initialize(target_proc, is_given_block = false)
      @target_proc = target_proc
      @return_value = []
      @args = []
      @given_block = is_given_block
      @called = false
    end

    def given_block?
      @given_block
    end

    def target_proc
      @target_proc
    end

    def return_value
      @return_value
    end

    def is_called?
      @called
    end

    def call(*args, &block)
      @called = true
      @args << args
      return_value = @target_proc.call(*args, &block)

      unless @return_value.include? return_value
        @return_value << return_value
      end

      return_value
    end

  end

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
              #puts \"local_variables\"
              v_locals = caller_context.eval('local_variables')

              v_locals.each { |v|
                variable_value = caller_context.eval(\"\#{v.to_s}\")
                @_let_variables[variable_value.object_id] = v
              }

              #{newStandInKlass}.replace_procs_with_recorders(arguments)

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
                if (@_instance.methods.include? method_sym)
                  result = @_instance.send(method_sym, *arguments, &recordedProc)
                else
                  result = @_instance.send(:method_missing, method_sym, *arguments, &recordedProc)
                end
                info_block[:result] = result
              rescue Exception=>e
                info_block[:result] = e
              rescue StandardError=>e
                info_block[:result] = e
              end

              @_method_calls << info_block

              if (@_method_calls_by_method[method_sym].nil?)
                @_method_calls_by_method[method_sym] = []
              end

              @_method_calls_by_method[method_sym] << info_block
              raise e if (e.kind_of? Exception)
              result"

      newStandInKlass.class_eval("
        def setup_instance(*args, &block)
          @_instance = #{klass.name}_ddt.new(*args, &block)
        end
      ")

      newStandInKlass.class_exec do



        def initialize(*args, &block)

          @_instance_init = {params: [], block: nil}

          self.class.replace_procs_with_recorders(args)

          @_instance_init[:params] = args

          recordedProc = if (block)
                          RecordedProc.new(block, true)
                         else
                           nil
                         end

          @_instance_init[:block] = recordedProc

          setup_instance(*args, &recordedProc)


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

        class << self

          def replace_procs_with_recorders(args)
            (0..args.size).each do |index|
              if (args[index].kind_of? Proc)
                args[index] = Pretentious::RecordedProc.new(args[index]) {}
              end
            end
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

        end

      end

      newStandInKlass.class_eval("
        def method_missing(method_sym, *arguments, &block)
          #puts \"\#{method_sym} \#{arguments}\"
          #{common_snippet}
        end

        class << self

            def test_class
              #{klass.name}
            end

            def method_missing(method_sym, *arguments, &block)
              #puts \"method \#{method_sym.to_s}\"
              _add_instances(self)
              @_instance = #{klass.name}_ddt
              #{common_snippet}
            end
        end
      ")

      newStandInKlass
    end

    def self.generate_for(*klasses_or_instances, &block)
      all_results = {}
      klasses = []

      klasses_or_instances.each { |klass_or_instance|
        klass = klass_or_instance.class == Class ? klass_or_instance : klass_or_instance.class


        klass_name_parts = klass.name.split('::')
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

        klasses << [module_space, klass, last_part, newStandInKlass]
      }

      watch_new_instances

      block.call

      unwatch_new_instances

      klasses.each { |module_space, klass, last_part, newStandInKlass|

        module_space.send(:remove_const,"#{last_part}Impostor".to_sym)
        module_space.send(:remove_const,"#{last_part}".to_sym)
        module_space.const_set(last_part, klass)
        module_space.send(:remove_const,"#{last_part}_ddt".to_sym)

        test_generator = Pretentious::RspecGenerator.new
        test_generator.begin_spec(klass)
        num = 1

        newStandInKlass._instances.each do |instance|
          test_generator.generate(instance, num)
          num+=1
        end unless newStandInKlass._instances.nil?

        test_generator.end_spec

        result = all_results[klass]
        if result.nil?
          all_results[klass] = []
        end

        all_results[klass] = test_generator.output

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
          @_variable_names= {}

          index = 0
          params = method(:initialize).parameters

          args.each do |arg|
            p = params[index]
            if p.size > 1
              @_variable_names[arg.object_id] = p[1].to_s
            end unless p.nil?
            index+=1
          end unless args.nil?

        end

        def _variable_map
          @_variable_names
        end

        def _deconstruct
          Pretentious::Deconstructor.new().deconstruct(self)
        end

        def _deconstruct_to_ruby(indentation = 0)
          Pretentious::Deconstructor.new().deconstruct_to_ruby(indentation, _variable_map, {}, self)
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

    def self.clean_watches
      Class.class_eval do
        remove_method :new
        alias_method :new, :_ddt_old_new
      end
    end

    def self.unwatch_new_instances
      Class.class_eval do
        remove_method :new
        alias_method :new, :_ddt_old_new
      end
    end

  end

end