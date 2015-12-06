module Pretentious
  # Contains references to scoped variables
  class Context
    attr_accessor :declared_names, :variable_map,
                  :previous_declarations

    def initialize(variable_map = {}, declared_names = {}, previous_declarations = {})
      @declared_names = declared_names
      @variable_map = variable_map
      @previous_declarations = previous_declarations
    end

    def subcontext(declarations)
      previous_declarations = {}

      declarations.select { |d| d[:used_by] != :inline }.each do |d|
        previous_declarations[d[:id]] = pick_name(d[:id])
      end

      Pretentious::Context.new(@variable_map, {}, previous_declarations)
    end

    def was_declared_previously?(object_id)
      @previous_declarations.key? object_id
    end

    def merge_variable_map(target_object)
      @variable_map.merge!(target_object._variable_map) if target_object.methods.include?(:_variable_map) && !target_object._variable_map.nil?
    end

    def register_instance_variable(object_id)
      @variable_map[object_id] = "@#{@previous_declarations[object_id]}" if @previous_declarations[object_id][0]!='@'
    end

    def register(object_id, name)
      @variable_map[object_id] = name
    end

    def dump
      puts "v-map #{@variable_map.inspect}"
      puts "d-map #{@declared_names.inspect}"
      puts "p-map #{@previous_declarations.inspect}"
    end

    def pick_name(object_id, value = :no_value_passed)
      var_name = "var_#{object_id}"

      object_id_to_declared_names = {}

      if @declared_names
        @declared_names.each { |k, v| object_id_to_declared_names[v[:object_id]] = k if v }
      end
      # return immediately if already mapped
      return object_id_to_declared_names[object_id] if object_id_to_declared_names.include? object_id

      if !@variable_map.nil? && @variable_map.include?(object_id)

        candidate_name = @variable_map[object_id].to_s
        if !@declared_names.include?(candidate_name)
          var_name = candidate_name
          @declared_names[candidate_name] = { count: 1, object_id: object_id }
        else

          if @declared_names[candidate_name][:object_id] == object_id
            var_name = candidate_name
          else
            new_name = "#{candidate_name}_#{@declared_names[candidate_name][:count]}"
            var_name = "#{new_name}"

            @declared_names[candidate_name][:count] += 1
            @declared_names[new_name] = { count: 1, object_id: object_id }
          end

        end
      else
        return value_of(value) if value != :no_value_passed
      end

      var_name
    end

    def value_of(value)
      Pretentious.value_ize(self, value)
    end
  end
end
