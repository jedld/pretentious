class Pretentious::Deconstructor

  class Reference
    attr_accessor :tree

    def initialize(tree)
      @tree = tree
    end
  end

  def dfs_array(arr, refs)
    value = []
    arr.each { |v|
      if Pretentious::Deconstructor.is_primitive?(v)
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
    }
    value
  end

  def dfs_hash(hash, refs)
    value = {}
    hash.each { |k, v|
      if Pretentious::Deconstructor.is_primitive?(v)
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
    }
    value
  end

  def dfs(tree)
    if !tree.is_a? Hash
      value = tree
      definition = {id: value.object_id, class: tree.class, value: value}
      unless (@dependencies.include? value.object_id)
        @dependencies[value.object_id] = definition
        @declaration_order << definition
      end
      value.object_id
    else
      ref = []

      definition = {id: tree[:id], class: tree[:class]}

      if tree[:class] == Hash
        definition[:value] = dfs_hash(tree[:composition], ref)
      elsif tree[:class] == Array
        definition[:value] = dfs_array(tree[:composition], ref)
      elsif tree[:class] == Pretentious::RecordedProc
        definition[:recorded_proc] = tree[:recorded_proc]
      elsif tree[:composition].is_a? Array
        tree[:composition].each { |t|
          ref << dfs(t)
        }
      else
        ref << dfs(tree[:composition])
      end

      definition[:ref] = ref

      unless (@dependencies.include? tree[:id])
        @declaration_order << definition
        @dependencies[tree[:id]] = definition
      end
      tree[:id]
    end
  end

  def deconstruct(*target_objects)

    @declaration_order = []
    @dependencies = {}

    target_objects.each { |target_object|
      tree = build_tree target_object
      dfs(tree)
    }

    {declaration: @declaration_order, dependency: @dependencies}
  end

  def deconstruct_to_ruby(indentation_level = 0, variable_map = {}, declared_names = {}, *target_objects)
    output_buffer = ""
    indentation = ""

    indentation_level.times {
      indentation << ' '
    }

    target_objects.each { |target_object|
      variable_map.merge!(target_object._variable_map) if target_object.methods.include?(:_variable_map) && !target_object._variable_map.nil?
    }

    declarations, dependencies = deconstruct *target_objects
    declarations[:declaration].each do |d|

      var_name = Pretentious::Deconstructor.pick_name(variable_map, d[:id], declared_names)
      output_buffer << "#{indentation}#{var_name} = #{construct(d, variable_map, declared_names, indentation)}\n"

    end

    output_buffer
  end

  def self.is_primitive?(value)
    value.is_a?(String) || value.is_a?(Fixnum) || value.is_a?(TrueClass) || value.is_a?(FalseClass) ||
        value.is_a?(NilClass) || value.is_a?(Symbol)
  end

  def self.block_param_names(proc)
    parameters_to_join = []

    parameters = proc.target_proc.parameters

    parameters.each { |p|
      parameters_to_join << p[1].to_s
    }
    parameters_to_join
  end

  def self.block_params_generator(proc, separator = '|')

    if (proc.target_proc.parameters.size > 0)
      return "#{separator}#{block_param_names(proc).join(', ')}#{separator}"
    end

    return ''
  end

  def proc_to_ruby(proc, let_variables, declared, indentation = '')
    output_buffer = ""
    output_buffer << "Proc.new { #{self.class.block_params_generator(proc)}\n"
    output_buffer << self.class.proc_body(proc, let_variables, declared, indentation)
    output_buffer << "#{indentation}}\n"
    output_buffer
  end

  def self.proc_body(proc, let_variables, declared,indentation = '')
    if (proc.return_value.size == 1)
      "#{indentation * 2}#{Pretentious::value_ize(proc.return_value[0], let_variables, declared)}\n"
    else
      "#{indentation * 2}\# Variable return values ... can't figure out what goes in here...\n"
    end
  end

  def deconstruct_array(array)
    composition = []
    array.each { |v|
      if (Pretentious::Deconstructor.is_primitive?(v))
        composition << v
      elsif v.is_a? Hash
        composition << deconstruct_hash(v)
      elsif v.is_a? Array
        composition << deconstruct_array(v)
      else
        composition << Reference.new(build_tree(v))
      end
    }
    composition
  end

  def deconstruct_hash(hash)
    composition = {}
    hash.each { |k, v|
      if (Pretentious::Deconstructor.is_primitive?(v))
        composition[k] = v
      elsif v.is_a? Hash
        composition[k] = deconstruct_hash(v)
      elsif v.is_a? Array
        composition[k] = deconstruct_array(v)
      else
        composition[k] = Reference.new(build_tree(v))
      end
    }
    composition
  end

  def deconstruct_proc(proc)
    if (proc.return_value.size == 1)
      return build_tree(proc.return_value[1])
    elsif (proc.return_value.size == 0)
      []
    else
      nil
    end
  end

  def get_test_class(target_object)
    target_object.respond_to?(:test_class) ? target_object.test_class : target_object.class
  end

  #creates a tree on how the object was created
  def build_tree(target_object)

    tree = {class: get_test_class(target_object), id: target_object.object_id, composition: []}
    if (target_object.is_a? Array)
      tree[:composition] = deconstruct_array(target_object)
    elsif target_object.is_a? Hash
      tree[:composition] = deconstruct_hash(target_object)
    elsif target_object.is_a? Pretentious::RecordedProc
      tree[:composition] = deconstruct_proc(target_object)
      tree[:recorded_proc] = target_object
      tree[:id] = target_object.target_proc.object_id
      tree[:block_params] = self.class.block_param_names(target_object)
    elsif target_object.methods.include? :_get_init_arguments
      args = target_object._get_init_arguments
      unless args.nil?
        args[:params].each { |p|
          tree[:composition] << build_tree(p)
        }

      else
        tree[:composition] = target_object
      end
    else
      tree[:composition] = target_object
    end
    tree
  end

  def self.pick_name(variable_map, object_id, declared_names = {})
    var_name = "var_#{object_id}"

    object_id_to_declared_names = {}

    declared_names.each { |k,v|
      object_id_to_declared_names[v[:object_id]] = k
    } if declared_names

    #return immediately if already mapped
    return object_id_to_declared_names[object_id] if (object_id_to_declared_names.include? object_id)

    if (!variable_map.nil? && variable_map.include?(object_id))

      candidate_name = variable_map[object_id].to_s

      if !declared_names.include?(candidate_name)
        var_name = candidate_name
        declared_names[candidate_name] = {count: 1, object_id: object_id}
      else

        if (declared_names[candidate_name][:object_id] == object_id)
          var_name = candidate_name
        else
          new_name = "#{candidate_name}_#{declared_names[candidate_name][:count]}"
          var_name = "#{new_name}"

          declared_names[candidate_name][:count]+=1
          declared_names[new_name] = {count: 1, object_id: object_id}
        end

      end
    end

    var_name
  end

  private


  def output_array(arr, variable_map, declared_names)
    output_buffer = '['
    array_elements = []
    arr.each { |v|
      value = Pretentious::value_ize(v, variable_map, declared_names)
      if (v.is_a? Hash)
        value = output_hash(v, variable_map, declared_names)
      elsif (v.is_a? Array)
        value = output_array(v, variable_map, declared_names)
      elsif (v.is_a? Reference)
        value = Pretentious::Deconstructor.pick_name(variable_map, v.tree, declared_names)
      end
      array_elements << value
    }
    output_buffer << array_elements.join(', ')
    output_buffer << ']'
    output_buffer
  end

  def output_hash(hash, variable_map, declared_names)
    output_buffer = '{'
    hash_elements = []
    hash.each { |k, v|
      value = Pretentious::value_ize(v, variable_map, declared_names)
      if (v.is_a? Hash)
        value = output_hash(v, variable_map, declared_names)
      elsif (v.is_a? Array)
        value = output_array(v, variable_map, declared_names)
      elsif (v.is_a? Reference)
        value = Pretentious::Deconstructor.pick_name(variable_map, v.tree, declared_names)
      end

      if (k.is_a? Symbol)
        hash_elements << "#{k}: #{value}"
      else
        hash_elements << "#{Pretentious::value_ize(k, variable_map, declared_names)} => #{value}"
      end
    }
    output_buffer << hash_elements.join(', ')
    output_buffer << '}'
    output_buffer
  end

  def construct(definition, variable_map, declared_names, indentation = '')
    if (definition[:value])
      if (definition[:value].is_a? Hash)
        output_hash(definition[:value], variable_map, declared_names)
      elsif (definition[:value].is_a? Array)
        output_array(definition[:value], variable_map, declared_names)
      else
        Pretentious::value_ize(definition[:value], variable_map, declared_names)
      end
    elsif (definition[:class] == Pretentious::RecordedProc)
      proc_to_ruby(definition[:recorded_proc], variable_map, declared_names, indentation)
    else
      params = []
      if (definition[:ref].size > 0)
        definition[:ref].each do |v|
          params << Pretentious::Deconstructor.pick_name(variable_map,v, declared_names)
        end
        "#{definition[:class]}.new(#{params.join(', ')})"
      else
        "#{definition[:class]}.new"
      end

    end
  end

end