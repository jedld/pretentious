module Pretentious
  class LazyTrigger
    attr_accessor :target_class, :options

    def initialize(target_class, options = {})
      @target_class = target_class
      @options = options
      Pretentious::LazyTrigger.register_instance(self)
    end

    class << self
      def lookup(class_name)
        @instance.each do |instance|
          return instance if instance.target_class == class_name
        end
        return null
      end

      protected

      def register_instance(instance)
        @instances ||= []
        @instances << instance unless @instances.include? instances
      end
    end
  end
end
