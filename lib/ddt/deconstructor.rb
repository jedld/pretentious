class Ddt::Deconstructor

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
      if tree[:composition].is_a? Array
      tree[:composition].each { |t|
        ref << dfs(t)
      }
      else
        ref << dfs(tree[:composition])
      end
      definition = {id: tree[:id], class: tree[:class], ref: ref}
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

  #creates a tree on how the object was created
  def build_tree(target_object)

    tree = {class: target_object.class, id: target_object.object_id, composition: []}
    if target_object.methods.include? :_get_init_arguments

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

  def construct(definition)
    if (definition[:value])
      Ddt::value_ize(definition[:value])
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