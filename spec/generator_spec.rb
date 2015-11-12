require 'spec_helper'

class TestClass

  def message(params1)
    @params1 = params1
  end

  def method_with_assign=(params2)
    @params2 = params2
  end
end

RSpec.describe Pretentious::Generator do

  context 'Pretentious::Generator#impostor_for' do
    before do
      @impostor = Pretentious::Generator.impostor_for(Object, TestClass)
    end

    it "should be a class" do
      expect(@impostor.kind_of? Class).to be
    end

    it "subject class should be valid" do
      expect(@impostor.test_class).to eq TestClass
    end

    it 'show contain the same methods' do
      expect(@impostor.instance_methods).to include :message
      expect(@impostor.instance_methods).to include :method_with_assign=
    end
  end

  context "Pretentious::Generator#replace_class" do

    around(:each) do |example|
      @old_class = TestClass
      module_space, klass, last, new_class = Pretentious::Generator.replace_class(TestClass)
      @new_class = new_class
      example.run
      Pretentious::Generator.restore_class(module_space, klass, last)
    end

    it "new class should be named like the old class" do
      expect(@new_class.to_s).to eq "TestClassImpostor"
      expect(TestClass == @new_class).to be
    end

    it "a new kind of class should be created" do
      expect(@old_class == @new_class).to_not be
    end

    it "should set instance variables like the real thing" do
      instance = @new_class.new
      instance.message("hello")
      expect(instance.instance_variable_get(:@params1)).to eq "hello"
    end
  end
end
