module Pretentious
  # A class that generates specs by analyzing how an object is used
  class Generator

    def self.test_generator=(generator)
      @test_generator = generator
    end

    def self.test_generator
      @test_generator || Pretentious::RspecGenerator
    end

    def self.impostor_for(module_space, klass)
      new_standin_klass = Class.new
      name = klass.name

      # return if already an impostor
      return klass if klass.respond_to?(:test_class)

      module_space.const_set "#{name.split('::').last}Impostor", new_standin_klass

      new_standin_klass.class_eval("
        def setup_instance(*args, &block)
          @_instance = #{klass.name}_ddt.new(*args, &block)
        end
      ")

      new_standin_klass.class_eval("
        class << self
          def _get_standin_class
            #{new_standin_klass}
          end

          def test_class
            #{klass.name}
          end

          def _current_old_class
            #{klass.name}_ddt
          end
        end
      ")

      new_standin_klass.class_exec do

        def initialize(*args, &block)
          #check for special invocations
          an_instance = if args[0] == :_no_init
            _cmd, an_instance = args.shift(2)
            an_instance
          else
            nil
          end
          @_instance_init = { object_id: object_id, params: [], block: nil }

          self.class.replace_procs_with_recorders(args)

          @_instance_init[:params] = args
          recorded_proc = block ? RecordedProc.new(block, true) : nil

          @_instance_init[:block] = recorded_proc

          @_instance = if an_instance
                         an_instance
                       else
                         setup_instance(*args, &recorded_proc)
                       end

          param_types = @_instance.method(:initialize).parameters
          @_instance_init[:params_types] = param_types

          @_method_calls = []
          @_method_calls_by_method = {}
          @_methods_for_test = []
          @_let_variables = {}

          @_init_let_variables = {}

          caller_context = binding.of_caller(2)
          v_locals = caller_context.eval('local_variables')

          v_locals.each do |v|
            begin
              variable_value = caller_context.eval("#{v.to_s}")
              @_init_let_variables[variable_value.object_id] = v
            rescue NoMethodError
            end
          end

          args.each_with_index do |a, index|
            @_init_let_variables[a.object_id] = param_types[index][1].to_s if param_types.size == 2
          end

          self.class._add_instances(self)
        end

        def _init_arguments
          @_instance_init
        end

        def _get_init_arguments
          @_instance_init
        end

        def test_class
          @_instance.class
        end

        def include_for_tests(method_list = [])
          @_methods_for_test += method_list
        end

        def let_variables
          @_let_variables
        end

        def init_let_variables
          @_init_let_variables.dup
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

        def impostor?
          true
        end

        def ==(other)
          @_instance == other
        end

        def kind_of?(klass)
          @_instance.is_a? klass
        end

        def methods
          @_instance.methods + [:method_calls]
        end

        # don't really freeze
        def freeze
          @_instance
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

          def impostor?
            true
          end

          def replace_procs_with_recorders(args)
            (0..args.size).each do |index|
              if args[index].kind_of? Proc
                args[index] = Pretentious::RecordedProc.new(args[index]) {}
              end
            end
          end

          def _set_is_stub
            @_is_stub = true
          end

          def _is_stub?
            @_is_stub ||= false
            @_is_stub
          end

          def _add_instances(instance)
            @_instances ||= []
            @_instances << instance unless @_instances.include? instance
          end

          def let_variables
            @_let_variables ? @_let_variables.dup : {}
          end

          def method_calls_by_method
            @_method_calls_by_method
          end

          def method_calls
            @_method_calls
          end

          def _add_instances(instance)
            @_instances ||= []
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
            klass = nil
            begin
              klass = _get_standin_class
            rescue NameError=>e
              result = nil
              target.instance_exec do
                result = if @_instance.methods.include? method_sym
                           @_instance.send(method_sym, *arguments, &block)
                         else
                           @_instance.send(:method_missing, method_sym,
                                           *arguments, &block)
                         end
              end
              return result
            end

            caller_context = binding.of_caller(2)

            is_stub = _is_stub?

            target.instance_exec do
              @_method_calls ||= []
              @_method_calls_by_method ||= {}
              @_methods_for_test ||= []
              @_let_variables ||= {}

              v_locals = caller_context.eval('local_variables')

              v_locals.each do |v|
                begin
                  variable_value = caller_context.eval("#{v}")
                  @_let_variables[variable_value.object_id] = v
                rescue NoMethodError
                end
              end

              klass.replace_procs_with_recorders(arguments)

              info_block = {}
              info_block[:method] = method_sym
              info_block[:params] = arguments

              recorded_proc = block ? RecordedProc.new(block, true) : nil

              info_block[:block] = recorded_proc

              begin

                unless is_stub
                  current_context = { calls: [] }
                  info_block[:context] = current_context

                  Thread.current._push_context(current_context)
                end

                if @_instance.methods.include? method_sym
                  info_block[:names] = @_instance.method(method_sym).parameters
                  result = @_instance.send(method_sym, *arguments, &recorded_proc)
                else
                  result = @_instance.send(:method_missing, method_sym, *arguments, &recorded_proc)
                end

                Thread.current._pop_context unless is_stub

                # methods that end with = are a special case with return values
                if method_sym.to_s.end_with? '='
                  info_block[:result] = arguments[0]
                else
                  info_block[:result] = result
                end
              rescue StandardError => e
                info_block[:result] = e
              end

              if is_stub
                info_block[:class] = test_class
                Thread.current._all_context.each do |mock_context|
                  mock_context[:calls] << info_block if mock_context
                end
              end

              @_method_calls << info_block

              if @_method_calls_by_method[method_sym].nil?
                @_method_calls_by_method[method_sym] = []
              end

              @_method_calls_by_method[method_sym] << info_block
              fail e if e.is_a? Exception
              result
            end
          end
        end
      end

      new_standin_klass.class_exec do
        def method_missing(method_sym, *arguments, &block)
          self.class._call_method(self, method_sym, *arguments, &block)
        end

        class << self
            def method_missing(method_sym, *arguments, &block)
              _add_instances(self)
              @_instance = _current_old_class
              _call_method(self, method_sym, *arguments, &block)
            end

            def const_missing(sym)
              _add_instances(self)
              @_instance = _current_old_class
              @_instance.const_get(sym)
            end
        end
      end

      new_standin_klass
    end

    def self.denamespace(klass)
      klass_name_parts = klass.name.split('::')
      last_part = klass_name_parts.pop

      module_space = Object

      if klass_name_parts.size > 0
        klass_name_parts.each do |part|
          module_space = module_space.const_get(part)
        end
      end

      [last_part, module_space]
    end

    def self.replace_class(klass, stub = false)
      last_part, module_space = denamespace(klass)
      new_standin_klass = impostor_for module_space, klass

      new_standin_klass._set_is_stub if stub

      module_space.send(:remove_const, last_part.to_sym)
      module_space.const_set("#{last_part}_ddt", klass)
      module_space.const_set("#{last_part}", new_standin_klass)

      [module_space, klass, last_part, new_standin_klass]
    end

    def self.restore_class(module_space, klass, last_part)
      module_space.send(:remove_const, "#{last_part}Impostor".to_sym) if Object.const_defined?("#{last_part}Impostor")
      module_space.send(:remove_const, "#{last_part}".to_sym) if Object.const_defined?(last_part)
      module_space.const_set(last_part, klass)
      module_space.send(:remove_const, "#{last_part}_ddt".to_sym) if Object.const_defined?("#{last_part}_ddt")
    end

    def self.generate_for(*klasses_or_instances, &block)
      all_results = {}
      klasses = []
      mock_dict = {}
      lazy_triggers = []
      klasses_or_instances.each do |klass_or_instance|
        if klass_or_instance.is_a?(String) || klass_or_instance.is_a?(Regexp)
          lazy_triggers << Pretentious::LazyTrigger.new(klass_or_instance, stubs: klass_or_instance._get_stub_classes)
        else
          klass = klass_or_instance.class == Class ? klass_or_instance : klass_or_instance.class
          klasses << replace_class(klass)

          mock_klasses = []

          klass._get_stub_classes.each do |mock_klass|
            mock_klasses << replace_class(mock_klass, true)
          end unless klass._get_stub_classes.nil?

          mock_dict[klass] = mock_klasses
        end
      end

      if !watched?
        watch_new_instances
        block.call
        unwatch_new_instances
      else
        block.call
      end

      # check for lazy triggers, collect and then clean
      klasses += Pretentious::LazyTrigger.collect_targets.map(&:to_a)
      lazy_triggers.each(&:disable!)
      klasses.each do |module_space, klass, last_part, new_standin_klass|
        # restore the previous class
        restore_class module_space, klass, last_part

        mock_dict[klass].each do |mock_module_space, mock_klass, mock_last_part, mock_new_standin_klass|
          restore_class mock_module_space, mock_klass, mock_last_part
        end if mock_dict[klass]

        generator = test_generator.new
        generator.begin_spec(klass)

        generator.body(new_standin_klass._instances) unless new_standin_klass._instances.nil?

        generator.end_spec

        result = all_results[klass]
        all_results[klass] = [] if result.nil?

        result_output = generator.output.is_a?(String) ? generator.output.chomp : generator.output
        all_results[klass] = { output: result_output, generator: generator.class }
      end unless klasses.nil?

      all_results
    end

    def self.watch_new_instances
      Object.class_eval do
        def _get_init_arguments
          @_init_arguments
        end

        def _set_init_arguments(*args, &block)
          @_init_arguments ||= {}
          @_init_arguments[:params] = args
          unless block.nil?
            @_init_arguments[:block] = RecordedProc.new(block) {}
          end
          @_variable_names = {}

          params = if self.respond_to? :test_class
                     test_class.instance_method(:initialize).parameters
                   else
                     self.class.instance_method(:initialize).parameters
                   end
          @_init_arguments[:params_types] = params

          args.each_with_index do |arg, index|
            p = params[index]
            @_variable_names[arg.object_id] = p[1].to_s if p && p.size > 1
          end unless args.nil?
        end

        def _variable_map
          (@_variable_names || {}).dup
        end

        def _deconstruct
          Pretentious::Deconstructor.new.deconstruct([], self)
        end

        def _deconstruct_to_ruby(var_name = nil, indentation = 0)
          variable_names = {}

          caller_context = binding.of_caller(1)
          v_locals = caller_context.eval('local_variables')

          v_locals.each do |v|
            variable_value = caller_context.eval("#{v}")
            if object_id == variable_value.object_id
              variable_names[variable_value.object_id] = v
            end
          end

          context = Pretentious::Context.new(_variable_map.merge!(variable_names))
          context.register(object_id, var_name) if var_name

          Pretentious::Deconstructor.new.deconstruct_to_ruby(context, indentation, self)
        end
      end

      # make sure it is set only once
      unless Class.instance_methods.include?(:_ddt_old_new)
        Class.class_eval do
          alias_method :_ddt_old_new, :new

          def new(*args, &block)
            lazy_trigger = Pretentious::LazyTrigger.lookup(self.to_s)
            instance = nil
            if !lazy_trigger.nil?
              klass = self
              instance = if methods.include? :_current_old_class
                           _ddt_old_new(*args, &block)
                         else
                           module_space, klass, last_part, stand_in_class = Pretentious::Generator.replace_class(self)
                           lazy_trigger.register_class(module_space, klass, last_part, stand_in_class)
                           inst = _ddt_old_new(*args, &block)
                           stand_in_class.new(*([:_no_init, inst] + args), &block)
                         end
            else
              instance = _ddt_old_new(*args, &block)
            end

            # rescues for handling native objects that don't have standard methods
            begin
              if instance.respond_to?(:_set_init_arguments) && !instance.respond_to?(:impostor?) && !instance.frozen?
                instance._set_init_arguments(*args, &block)
              end
            rescue NoMethodError
              begin
                puts "no method error"
                instance._set_init_arguments(*args, &block)
              rescue NoMethodError
                # eat up NoMethodError for now
              end
            end

            instance
          end
        end
      end
    end

    def self.clean_watches
      unwatch_new_instances
    end

    def self.watched?
      Class.respond_to?(:_ddt_old_new)
    end

    def self.unwatch_new_instances
      if watched?
        Class.class_eval do
          remove_method :new
          alias_method :new, :_ddt_old_new
          remove_method :_ddt_old_new
        end
      end
    end
  end
end
