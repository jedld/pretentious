require "pretentious/version"
require "pretentious/rspec_generator"
require "pretentious/minitest_generator"
require "pretentious/recorded_proc"
require "pretentious/generator"
require 'binding_of_caller'
require 'pretentious/deconstructor'

Class.class_eval do

  def _stub(*classes)
    @classes = classes
    self
  end

  def _get_mock_classes
    @classes
  end

end

Thread.class_eval do

  def _push_context(context)
    @_context ||= []
    @_context << context
  end

  def _current_context
    @_context ||= []
    @_context.last
  end

  def _all_context
    @_context ||= []
  end

  def _pop_context
    @_context.pop
  end
end

module Pretentious

  def self.spec_for(*klasses, &block)
    @spec_results ||= {}
    Pretentious::Generator.test_generator = Pretentious::RspecGenerator
    @spec_results.merge!(Pretentious::Generator.generate_for(*klasses, &block))
  end

  def self.minitest_for(*klasses, &block)
    @minitest_results ||= {}
    Pretentious::Generator.test_generator = Pretentious::MinitestGenerator
    @minitest_results.merge!(Pretentious::Generator.generate_for(*klasses, &block))
  end

  def self.clear_results
    @spec_results = {}
    @minitest_results = {}
  end

  def self.last_results
    {spec: @spec_results,  minitest: @minitest_results}
  end

  def self.install_watcher
    Pretentious::Generator.watch_new_instances
  end

  def self.uninstall_watcher
    Pretentious::Generator.unwatch_new_instances
  end

  def self.value_ize(value, let_variables, declared_names)
    if (value.kind_of? String)
      "#{value.dump}"
    elsif (value.is_a? Symbol)
      ":#{value.to_s}"
    elsif (value.is_a? Hash)
      Pretentious::Deconstructor.pick_name(let_variables, value.object_id, declared_names)
    elsif (value.is_a? Pretentious::RecordedProc)
      Pretentious::Deconstructor.pick_name(let_variables, value.target_proc.object_id, declared_names)
    elsif (value == nil)
      "nil"
    else
      "#{value.to_s}"
    end
  end

  def self.watch(&block)
    Pretentious::Generator.watch_new_instances
    result = block.call
    Pretentious::Generator.unwatch_new_instances
    result
  end


end