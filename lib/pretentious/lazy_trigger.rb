module Pretentious
  class LazyTrigger
    attr_accessor :target_class, :options, :instances

    def initialize(target_class, options = {})
      @target_class = target_class
      @options = options
      @instances = []
      Pretentious::LazyTrigger.register_instance(self)
    end

    def disable!
      Pretentious::LazyTrigger.unregister_instance(self)
    end

    def register_class(klass)
      @instances << klass unless @instances.include? klass
    end

    class << self
      def lookup(class_name)
        @instances ||= []
        @instances.each do |instance|
          return instance if instance.target_class == class_name
        end
        nil
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
