class Ddt::Deconstructor

  class Reference
    attr_accessor :tree

    def initialize(tree)
      @tree = tree
    end
  end

  def dfs_array(arr, refs)
    value = []
    arr.each { |v|
      if Ddt::Deconstructor.is_primitive?(v)
        value << v
      elsif v.is_a? Hash
        value << dfs_hash(v, refs)
      elsif v.is_a? Array
        value << dfs_array(v, refs)
      elsif v.is_a? Reference
        refs << v.tree[:id]
        value << dfs(v.tree)
      elsif
        value << v
      end
    }
    value
  end

  def dfs_hash(hash, refs)
    value = {}
    hash.each { |k,v|
      if Ddt::Deconstructor.is_primitive?(v)
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
      elsif tree[:composition].is_a? Array
        tree[:composition].each { |t|
          ref << dfs(t)
        }
      else
        ref << dfs(tree[:composition])
      end

      definition[:ref] =  ref

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

  def deconstruct_to_ruby(indentation_level = 0, variable_map = nil, *target_objects)
    output_buffer = ""
    indentation = ""

    indentation_level.times {
      indentation << " "
    }

    declarations, dependencies = deconstruct *target_objects
    declarations[:declaration].each do |d|
      var_name = "#{indentation}var_#{d[:id]}"

      if (!variable_map.nil? && variable_map.include?(d[:id]))
        var_name = "#{indentation}#{variable_map[d[:id]].to_s}"
      end

      output_buffer << "#{indentation}#{var_name} = #{construct(d)}\n"
    end

    output_buffer
  end

  def self.is_primitive?(value)
    value.is_a?(String) || value.is_a?(Fixnum) || value.is_a?(TrueClass) || value.is_a?(FalseClass) ||
        value.is_a?(NilClass) || value.is_a?(Symbol)
  end

  def deconstruct_array(array)
    composition = []
    array.each { | v|
      if (is_primitive?(v))
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
      if (Ddt::Deconstructor.is_primitive?(v))
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

  #creates a tree on how the object was created
  def build_tree(target_object)

    tree = {class: target_object.class, id: target_object.object_id, composition: []}
    if (target_object.is_a? Array)
      tree[:composition] = deconstruct_array(target_object)
    elsif target_object.is_a? Hash
      tree[:composition] = deconstruct_hash(target_object)
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

  private

  def output_array(arr)
    output_buffer = '['
    array_elements = []
    arr.each { |v|
      value = Ddt::value_ize(v)
      if (v.is_a? Hash)
        value = output_hash(v)
      elsif (v.is_a? Array)
        value = output_array(v)
      elsif (v.is_a? Reference)
        value = "var_#{v.tree[:id]}"
      end
      array_elements << value
    }
    output_buffer << array_elements.join(', ')
    output_buffer << ']'
    output_buffer
  end

  def output_hash(hash)
    output_buffer = '{'
    hash_elements = []
    hash.each { |k,v|
      value = Ddt::value_ize(v)

      if (v.is_a? Hash)
        value = output_hash(v)
      elsif (v.is_a? Array)
        value = output_array(v)
      elsif (v.is_a? Reference)
        value = "var_#{v.tree}"
      end

      if (k.is_a? Symbol)
        hash_elements << "#{k}: #{value}"
      else
        hash_elements << "#{Ddt::value_ize(k)} => #{value}"
      end
    }
    output_buffer << hash_elements.join(', ')
    output_buffer << '}'
    output_buffer
  end

  def construct(definition)
    if (definition[:value])
      if (definition[:value].is_a? Hash)
        output_hash(definition[:value])
      elsif (definition[:value].is_a? Array)
      else
        Ddt::value_ize(definition[:value])
      end
    else
      params = []
      if (definition[:ref].size > 0)
        definition[:ref].each do |v|
          params << "var_#{v}"
        end
        "#{definition[:class]}.new(#{params.join(', ')})"
      else
        "#{definition[:class]}.new"
      end

    end
  end

end