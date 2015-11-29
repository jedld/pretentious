require 'spec_helper'

RSpec.describe Pretentious::Deconstructor do

  before do
    @fixture = Pretentious::Deconstructor.new
  end

  describe "#build_tree" do

    it "should decompose an object" do

      message = "test"
      another_object = Pretentious.watch {
        TestClass1.new(message)
      }

      # Pretentious::Deconstructor#build_tree when passed target_object = #<TestClass1:0x00000102d82860> should return {:class=>TestClass1, :id=>2171343920, :composition=>[{:class=>String, :id=>2171343600, :composition=>"test"}]}
      expect( @fixture.build_tree(another_object) ).to eq({class: TestClass1, id: another_object.object_id,
                                                           composition: [{:class=>String, :id=>message.object_id, :composition=>"test"}]})

    end
  end

  describe "#deconstruct" do

    it "should build list of variables to declare" do
      message = "test"
      another_object = Pretentious.watch {
        TestClass1.new(message)
      }

      decons = @fixture.deconstruct([], another_object)
      expect( decons ).to eq({declaration: [
          { id: message.object_id, class: String, :value=>"test"},
          { id: another_object.object_id, class: TestClass1, :ref=>[message.object_id]}],
          dependency: {message.object_id=>{id: message.object_id, class: String, value: "test"},
                       another_object.object_id=>{id: another_object.object_id, class: TestClass1,
                      ref: [message.object_id]}}
                             })
    end

  end

end
