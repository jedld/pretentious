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

    before do
      @result = Pretentious::Generator.replace_class(TestClass)
      @new_class = @result[1]
    end


    it "should set instance variables like the real thing" do
      instance = @new_class.new
      instance.message("hello")
      expect(instance.instance_variable_get(:@params1)).to eq "hello"
    end
  end
end
