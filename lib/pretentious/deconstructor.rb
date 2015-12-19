module Pretentious
  # Deconstructor - decompose an object into its parts
  class Deconstructor
    # Represents an unresolved class
    class UnResolved
      attr_accessor :target_object

      def initialize(object)
        @target_object = object
      end
    end

    # Represents a reference
    class Reference
      attr_accessor :tree

      def initialize(tree)
        @tree = tree
      end
    end

    def dfs_array(arr, refs)
      value = []
      arr.each do |v|
        if Pretentious::Deconstructor.primitive?(v)
          value << v
        elsif v.is_a? Hash
          value << dfs_hash(v, refs)
        elsif v.is_a? Array
          value << dfs_array(v, refs)
        elsif v.is_a? Reference
          refs << v.tree[:id]
          value << Reference.new(dfs(v.tree))
        elsif value << v
        end
      end
      value
    end

    def dfs_hash(hash, refs)
      value = {}
      hash.each do |k, v|
        if Pretentious::Deconstructor.primitive?(v)
          value[k] = v
        elsif v.is_a? Hash
          value[k] = dfs_hash(v, refs)
        elsif v.is_a? Array
          value[k] = dfs_array(v, refs)
        elsif v.is_a? Reference
          refs << v.tree[:id]
          value[k] = Reference.new(dfs(v.tree))
        else
          value[k] = v
        end
      end
      value
    end

    def dfs(tree)
      if !tree.is_a? Hash
        value = tree
        definition = { id: value.object_id,
                       class: tree.class,
                       value: value,
                       used_by: [] }
        unless @dependencies.include? value.object_id
          @dependencies[value.object_id] = definition
          @declaration_order << definition
        end
        value.object_id
      else
        ref = []

        definition = { id: tree[:id],
                       class: tree[:class],
                       params_types: tree[:params_types],
                       used_by: [] }

        if tree[:class] == Hash
          definition[:value] = dfs_hash(tree[:composition], ref)
        elsif tree[:class] == Array
          definition[:value] = dfs_array(tree[:composition], ref)
        elsif tree[:class] == Pretentious::RecordedProc
          definition[:recorded_proc] = tree[:recorded_proc]

          if !tree[:composition].nil?
            ref << dfs(tree[:composition])
          else
            dfs(tree[:composition])
          end

        elsif tree[:composition].is_a? Array
          tree[:composition].each { |t| ref << dfs(t) }
        else
          ref << dfs(tree[:composition])
        end

        # evaluate given block composition
        ref << dfs(tree[:block]) if tree[:block]

        definition[:ref] = ref

        unless @dependencies.include? tree[:id]
          @declaration_order << definition
          @dependencies[tree[:id]] = definition

          ref.each { |r| @dependencies[r][:used_by] << definition }
        end

        tree[:id]
      end
    end

    def update_ref_counts(params_arr, method_call)
      params_arr.each do |p|
        if @dependencies.include? p.object_id
          @dependencies[p.object_id][:used_by] << method_call
        end
      end
    end

    def inline
      @dependencies.each do |id, definition|
        next if definition[:used_by].size != 1
        next if !definition.include?(:value) || !self.class.primitive?(definition[:value])
        ref = definition[:used_by][0]
        definition[:used_by] = :inline
        references = ref[:ref]
        if references
          new_ref = references.collect { |c| c == id ? definition : c }
          ref[:ref] = new_ref
        end
      end
    end

    # creates a tree on how the object was created
    def build_tree(target_object)
      tree = { class: get_test_class(target_object), id: target_object.object_id, composition: [] }
      if target_object.is_a? Array
        tree[:composition] = deconstruct_array(target_object)
      elsif target_object.is_a? Hash
        tree[:composition] = deconstruct_hash(target_object)
      elsif target_object.is_a? Pretentious::RecordedProc
        tree[:composition] = deconstruct_proc(target_object)
        tree[:given_block] = target_object.given_block?
        tree[:recorded_proc] = target_object
        tree[:id] = target_object.target_proc.object_id
        tree[:block_params] = self.class.block_param_names(target_object)
      elsif target_object.methods.include? :_get_init_arguments
        args = target_object._get_init_arguments
        if args.nil?
          if self.class.primitive?(target_object)
            tree[:composition] = target_object
          elsif target_object.class == File
            tree[:composition] << build_tree(target_object.path)
          else
            tree[:composition] = UnResolved.new(target_object)
          end
        else
          tree[:params_types] = args[:params_types]
          args[:params].each { |p| tree[:composition] << build_tree(p) }

          tree[:block] = build_tree(args[:block]) unless args[:block].nil?
        end

      else
        tree[:composition] = target_object
      end
      tree
    end

    def deconstruct(method_call_collection, *target_objects)
      @declaration_order = []
      @dependencies = {}

      target_objects.each do |target_object|
        tree = build_tree target_object
        dfs(tree)
      end

      method_call_collection.each do |m|
        update_ref_counts(m[:params], m)
      end

      inline

      { declaration: @declaration_order, dependency: @dependencies }
    end

    def generate_declarations(context, method_call_collection, *target_objects)
      target_objects.each do |target_object|
        context.merge_variable_map(target_object)
      end
      deconstruct method_call_collection, *target_objects
    end

    def build_output(context, indentation_level, declarations)
      output_buffer = ''
      indentation = ''
      indentation_level.times { indentation << ' ' }
      declarations[:declaration].select { |d| d[:used_by] != :inline }.each do |d|
        if !context.was_declared_previously?(d[:id])
          var_name = context.pick_name(d[:id])
          output_buffer << "#{indentation}#{var_name} = #{construct(context, d, indentation)}\n"
        elsif context.was_declared_previously?(d[:id])
          context.register_instance_variable(d[:id])
        end
      end
      output_buffer
    end

    def deconstruct_to_ruby(context, indentation_level = 0, *target_objects)
      declarations, _dependencies = generate_declarations context, [], *target_objects
      build_output(context, indentation_level, declarations)
    end

    def self.primitive?(value)
      value.is_a?(String) || value.is_a?(Fixnum) || value.is_a?(TrueClass) || value.is_a?(FalseClass) ||
        value.is_a?(NilClass) || value.is_a?(Symbol) || value.is_a?(Class)
    end

    def self.block_param_names(proc)
      parameters_to_join = []

      parameters = proc.target_proc.parameters

      parameters.each { |p| parameters_to_join << p[1].to_s }
      parameters_to_join
    end

    def self.block_params_generator(proc, separator = '|')
      if proc.target_proc.parameters.size > 0
        return "#{separator}#{block_param_names(proc).join(', ')}#{separator}"
      end

      ''
    end

    def proc_to_ruby(context, proc, indentation = '')
      output_buffer = ''
      output_buffer << "proc { #{self.class.block_params_generator(proc)}\n"
      output_buffer << self.class.proc_body(context, proc, indentation)
      output_buffer << "#{indentation}}\n"
      output_buffer
    end

    def self.proc_body(context, proc, indentation = '')
      if proc.return_value.size == 1
        "#{indentation}  #{context.value_of(proc.return_value[0])}\n"
      else
        "#{indentation}  \# Variable return values ... can't figure out what goes in here...\n"
      end
    end

    def deconstruct_array(array)
      composition = []
      array.each do |v|
        if Pretentious::Deconstructor.primitive?(v)
          composition << v
        elsif v.is_a? Hash
          composition << deconstruct_hash(v)
        elsif v.is_a? Array
          composition << deconstruct_array(v)
        else
          composition << Reference.new(build_tree(v))
        end
      end
      composition
    end

    def deconstruct_hash(hash)
      composition = {}
      hash.each do |k, v|
        if Pretentious::Deconstructor.primitive?(v)
          composition[k] = v
        elsif v.is_a? Hash
          composition[k] = deconstruct_hash(v)
        elsif v.is_a? Array
          composition[k] = deconstruct_array(v)
        else
          composition[k] = Reference.new(build_tree(v))
        end
      end
      composition
    end

    def deconstruct_proc(proc)
      return nil if proc.return_value.size != 1
      return build_tree(proc.return_value[0]) unless proc.return_value[0].nil?
    end

    def get_test_class(target_object)
      target_object.respond_to?(:test_class) ? target_object.test_class : target_object.class
    end

    private

    def output_array(context, arr)
      output_buffer = '['
      array_elements = []
      arr.each do |v|
        value = Pretentious.value_ize(context, v)
        if v.is_a? Hash
          value = output_hash(context, v)
        elsif v.is_a? Array
          value = output_array(context, v)
        elsif v.is_a? Reference
          value = context.pick_name(v.tree)
        end
        array_elements << value
      end
      output_buffer << array_elements.join(', ')
      output_buffer << ']'
      output_buffer
    end

    def output_hash(context, hash)
      output_buffer = '{ '
      hash_elements = []
      hash.each do |k, v|
        value = context.value_of(v)
        if v.is_a? Hash
          value = output_hash(context, v)
        elsif v.is_a? Array
          value = output_array(context, v)
        elsif v.is_a? Reference
          value = context.pick_name(v.tree)
        end

        if k.is_a? Symbol
          hash_elements << "#{k}: #{value}"
        else
          hash_elements << "#{context.value_of(k)} => #{value}"
        end
      end
      output_buffer << hash_elements.join(', ')
      output_buffer << ' }'
      output_buffer
    end

    def construct(context, definition, indentation = '')
      if definition.include? :value
        if definition[:value].is_a? Hash
          output_hash(context, definition[:value])
        elsif definition[:value].is_a? Array
          output_array(context, definition[:value])
        elsif definition[:value].is_a? UnResolved
          "#{definition[:value].target_object.class.to_s}.new # parameters unresolvable. The watcher needs to be installed before this object is created"
        else
          context.value_of(definition[:value])
        end
      elsif definition[:class] == Pretentious::RecordedProc
        proc_to_ruby(context, definition[:recorded_proc], indentation)
      else
        params = []
        if definition[:ref] && definition[:ref].size > 0

          params_types = definition[:params_types]
          definition[:ref].each_with_index do |v, index|
            type = :param
            if params_types && params_types[index]
              type = params_types[index][0]
            end

            # to inline?
            if v.is_a? Hash
              params << context.value_of(v[:value])
            else
              params << (type == :block ? "&#{context.pick_name(v)}" : context.pick_name(v))
            end
          end
          "#{definition[:class]}.new(#{params.join(', ')})"
        else
          "#{definition[:class]}.new"
        end

      end
    end

  end
end
