require "ddt/version"
require "ddt/generator"
require "ddt/rspec_generator"

module Ddt

  class Generator

    def self.generate_for(klass_or_instance, options = {}, args = [], &block)

      output_str = ""
      klass = klass_or_instance.class == Class ? klass_or_instance : klass_or_instance.class

      klass_name = klass.name
      test_generator = Ddt::RspecGenerator.new

      newStandInKlass = Class.new
      newStandInKlass.class_eval do

        def initialize(args)
          puts "new standin class"
          @_instance = klass.new(*args)
          @_method_calls = []
          @_methods_for_test = []

          @_instance
        end

        def test_class
          @_instance.class
        end

        def include_for_tests(method_list = [])
          @_methods_for_test = @_methods_for_test + method_list
        end

        def method_missing(method_sym, *arguments, &block)

          info_block = {}
          info_block[:method] = method_sym
          info_block[:params] = arguments

          if (@_instance.methods.include? :method_sym)
            result = @_instance.send(method_sym, *arguments, &block)
          else
            result = @_instance.send(:method_missing, method_sym, *arguments, &block)
          end

          info_block[:result] = result

          method_calls << info_block

          result
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

      end

      test_instance = newStandInKlass.new(args)
      block.call(test_instance)
      test_generator.generate(test_instance)
    end


  end

end