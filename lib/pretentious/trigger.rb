module Pretentious
  class Trigger
    class Options
      attr_accessor :output_folder
    end

    def initialize(target_class)
      @target_class = target_class
    end

    def method_called(*target_methods)
      @target_methods = target_methods
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
          @target_class.class_exec(@target_class, method, @spec_classes, @results_block, @generator, @options) do |klass, m, spec_classes,
              results_block, generator, options|

            if !klass.instance_methods.include? :"_pretentious_orig_#{m}"
              alias_method :"_pretentious_orig_#{m}", :"#{m}"
            end

            define_method(m.to_sym) do |*args, &block|
              result = nil
              Pretentious::Generator.test_generator = generator
              generator_result = Pretentious::Generator.generate_for(*spec_classes) do
                result = send(:"_pretentious_orig_#{m}", *args, &block)
              end

              results_block.call(generator_result, options) if results_block

              result
            end
        end
      }
      @options
    end
  end
end