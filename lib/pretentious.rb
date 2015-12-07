require 'pretentious/version'
require 'pretentious/context'
require 'pretentious/generator_base'
require 'pretentious/rspec_generator'
require 'pretentious/minitest_generator'
require 'pretentious/recorded_proc'
require 'pretentious/generator'
require 'binding_of_caller'
require 'pretentious/deconstructor'
require 'pretentious/trigger'
require 'pretentious/utils/file_writer'

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

# The main class to use for pretentious testing
module Pretentious
  # misc convenience tools
  module DdtUtils
    def self.to_underscore(str)
      str.gsub(/(.)([A-Z])/, '\1_\2').downcase
    end
  end

  def self.spec_for(*klasses, &block)
    @spec_results ||= {}
    Pretentious::Generator.test_generator = Pretentious::RspecGenerator
    @spec_results.merge!(Pretentious::Generator
                         .generate_for(*klasses, &block))
  end

  def self.minitest_for(*klasses, &block)
    @minitest_results ||= {}
    Pretentious::Generator.test_generator = Pretentious::MinitestGenerator
    @minitest_results.merge!(Pretentious::Generator
                             .generate_for(*klasses, &block))
  end

  def self.clear_results
    @spec_results = {}
    @minitest_results = {}
  end

  def self.last_results
    { spec: @spec_results, minitest: @minitest_results }
  end

  def self.install_watcher
    Pretentious::Generator.watch_new_instances
  end

  def self.uninstall_watcher
    Pretentious::Generator.unwatch_new_instances
  end

  def self.value_ize(context, value)
    if value.is_a? String
      "'#{value}'"
    elsif value.is_a? Symbol
      ":#{value}"
    elsif value.is_a? Hash
      context.pick_name(value.object_id)
    elsif value.is_a? Pretentious::RecordedProc
      context.pick_name(value.target_proc.object_id)
    elsif value.nil?
      'nil'
    elsif Pretentious::Deconstructor.primitive?(value)
      "#{value}"
    elsif context.variable_map && context.variable_map[value.object_id]
      context.pick_name(value.object_id)
    else
      "#{value}"
    end
  end

  def self.watch(&block)
    Pretentious::Generator.watch_new_instances
    result = block.call
    Pretentious::Generator.unwatch_new_instances
    result
  end

  def self.on(target_class)
    Pretentious::Trigger.new(target_class)
  end
end
