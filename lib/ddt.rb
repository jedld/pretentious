require "ddt/version"

  module Ddt

    class Generator

      def self.generate_for(klass_or_instance, &block)
        klass = klass_or_instance.class == Class ? klass_or_instance : klass_or_instance.class

        klass_name = klass.name

        newStandInKlass = Class.new
        newStandInKlass.class_eval do

          def initialize
            puts "new standin class"
            @instance = klass.new
            @method_calls = []
            @instance
          end

          def initialize(instance)
            @instance = instance
            @method_calls = []
          end

          def method_missing(method_sym, *arguments, &block)

            info_block = {}
            info_block[:method] = method_sym
            info_block[:params] = arguments

            if (@instance.methods.include? :method_sym)
              result = @instance.send(method_sym, *arguments, &block)
            else
              result = @instance.send(:method_missing, method_sym, *arguments, &block)
            end

            info_block[:result] = result

            method_calls << info_block

            result
          end

          def method_calls
            @method_calls
          end

          def to_s
            @instance.to_s
          end

          def ==(other)
            @instance==other
          end

          def kind_of?(klass)
            @instance.kind_of? klass
          end

          def methods
            @instance.methods + [:method_calls]
          end

          def freeze
            @instance.freeze
          end

          def hash
            @instance.hash
          end

          def inspect
            @instance.inspect
          end

          def is_a?(something)
            @instance.is_a? something
          end

        end
        begin
          Object.send(:remove_const, "#{klass_name}Old".to_sym)
        rescue NameError => e
        end

        Object.const_set "#{klass_name}Old".to_sym, klass
        Object.send(:remove_const, klass_name.to_sym)
        Object.const_set klass_name.to_sym, newStandInKlass
        block.call
        Object.const_set klass_name.to_sym, klass

      end


    end

end