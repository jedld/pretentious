module Pretentious
  # The trigger class is used for hooking into an existing method
  # in order to record the usage of a target class
  class Trigger
    # options that ca be passed to a trigger
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
      file_writer = FileWriter.new({ output_folder: output_folder })
      file_writer.write klass, result
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

      default_callback = proc do |result_per_generator, options|
        output_files = []
        result_per_generator.each do |klass, result|
          output_folder = result[:generator].location(options.output_folder)
          filename = Pretentious::Trigger.output_file(result, klass, output_folder)
          output_files << filename
        end
        output_files
      end

      @results_block = default_callback unless @results_block

      @target_methods.each do |method|
        @target_class.class_exec(@target_class, method) do |klass, m|
          unless klass.instance_methods.include? :"_pretentious_orig_#{m}"
            alias_method :"_pretentious_orig_#{m}", :"#{m}"
          end
        end

        attach_generator(@generator, @target_class, method, @spec_classes, @results_block, @options)
      end

      @target_class_methods.each do |method|
        @target_class.singleton_class.class_exec(@target_class, method) do |klass, m|
          unless klass.methods.include? :"_pretentious_orig_#{m}"
            alias_method :"_pretentious_orig_#{m}", :"#{m}"
          end
        end
        attach_generator(@generator, @target_class.singleton_class, method,
                         @spec_classes, @results_block, @options)
      end

      @options
    end
  end
end
