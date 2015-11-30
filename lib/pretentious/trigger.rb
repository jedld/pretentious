module Pretentious
  class Trigger
    class Options
      attr_accessor :output_folder
    end

    def initialize(target_class)
      @target_class = target_class
      @target_class_methods = []
      @target_methods = []
    end

    def method_called(*target_methods)
      @target_methods = target_methods
      self
    end

    def class_method_called(*target_methods)
      @target_class_methods = target_methods
      self
    end

    def spec_for(*klasses, &results_block)
      @generator = Pretentious::RspecGenerator
      @spec_classes = klasses
      @results_block = results_block
      install_trigger
    end

    def minitest_for(*klasses, &results_block)
      @generator = Pretentious::MinitestGenerator
      @spec_classes = klasses
      @results_block = results_block
      install_trigger
    end

    def self.output_file(result, klass, output_folder)
      FileUtils.mkdir_p output_folder
      result[:generator].helper(output_folder)
      filename = result[:generator].naming(output_folder, klass)
      File.open(filename, 'w') {
          |f| f.write(result[:output])
      }
      filename
    end

    private

    def attach_generator(generator, target, method, spec_classes, results_block, options)
      target.send(:define_method, method.to_sym) do |*args, &block|
          result = nil
          Pretentious::Generator.test_generator = generator
          generator_result = Pretentious::Generator.generate_for(*spec_classes) do
            result = send(:"_pretentious_orig_#{method}", *args, &block)
          end

          results_block.call(generator_result, options) if results_block

          result
        end
    end

    def install_trigger
      @options = Pretentious::Trigger::Options.new

      default_callback = Proc.new { |result_per_generator, options|
        output_files = []
        result_per_generator.each { |klass, result|
          output_folder = result[:generator].location(options.output_folder)
          filename = Pretentious::Trigger::output_file(result, klass, output_folder)
          output_files << filename
        }
        output_files
      }

      @results_block = default_callback unless @results_block

      @target_methods.each { |method|
          @target_class.class_exec(@target_class, method) do |klass, m|

            if !klass.instance_methods.include? :"_pretentious_orig_#{m}"
              alias_method :"_pretentious_orig_#{m}", :"#{m}"
            end

          end

          attach_generator(@generator, @target_class, method, @spec_classes, @results_block, @options)
      }

      @target_class_methods.each { |method|
        @target_class.singleton_class.class_exec(@target_class, method) do |klass, m|
          if !klass.methods.include? :"_pretentious_orig_#{m}"
            alias_method :"_pretentious_orig_#{m}", :"#{m}"
          end
        end
        attach_generator(@generator, @target_class.singleton_class, method, @spec_classes, @results_block, @options)
      }

      @options
    end
  end
end