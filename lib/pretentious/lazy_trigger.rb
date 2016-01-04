module Pretentious
  class LazyTrigger
    attr_accessor :target_class, :options, :targets

    class Target
      attr_accessor :stand_in_klass, :original_klass, :module_space, :name

      def initialize(module_space, klass, last_part, stand_in_class)
        @module_space = module_space
        @stand_in_klass = stand_in_class
        @original_klass = klass
        @name = last_part
      end

      def to_a
        [@module_space, @original_klass, @name, @stand_in_klass]
      end
    end

    def initialize(target_class, options = {})
      @target_class = target_class
      @options = options
      @targets = {}
      Pretentious::LazyTrigger.register_instance(self)
    end

    def disable!
      Pretentious::LazyTrigger.unregister_instance(self)
    end

    def restore
      @targets.each do |_stand_in_klass, target|
        Pretentious::Generator.restore_class target.module_space, target.original_klass, target.name
      end
    end

    def register_class(module_space, klass, last_part, stand_in_class)
      target = Pretentious::LazyTrigger::Target.new(module_space, klass, last_part, stand_in_class)
      @targets[target.stand_in_klass] = target unless @targets.include? target.stand_in_klass
    end

    def match(value)
      if @target_class.is_a? Regexp
        @target_class.match(value)
      elsif @target_class.is_a? String
        @target_class == value
      else
        @target_class.to_s == value
      end
    end

    class << self
      def generate_for_class(generator_class)
        all_results = {}
        Pretentious::LazyTrigger.collect_targets.each do |target|
          standin_klass = target.stand_in_klass
          klass = target.original_klass
          puts "generate for #{klass}"
          generator = generator_class.new

          generator.begin_spec(klass)
          generator.body(standin_klass._instances) unless standin_klass._instances.nil?
          generator.end_spec

          result = all_results[klass]
          all_results[klass] = [] if result.nil?

          result_output = generator.output.is_a?(String) ? generator.output.chomp : generator.output
          all_results[klass] = { output: result_output, generator: generator.class }
        end
        all_results
      end

      def lookup(class_name)
        @instances ||= []
        @instances.each do |instance|
          return instance if instance.match(class_name)
        end
        nil
      end

      def collect_targets
        artifacts = []
        @instances.each do |instance|
          instance.targets.values.each do |target|
            artifacts << target
          end
        end
        artifacts
      end

      def collect_artifacts
        artifacts = []
        @instances.each do |instance|
          instance.targets.values.each do |target|
            artifacts << target.stand_in_klass
          end
        end
        artifacts
      end

      def clear
        @instances = []
      end

      def register_instance(instance)
        @instances ||= []
        @instances << instance unless @instances.include? instance
      end

      def unregister_instance(instance)
        @instances.delete(instance)
      end
    end
  end
end
