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
      expect( @fixture.build_tree(another_object) ).to eq({:class=>TestClass1, :id=>another_object.object_id,
                                                           :composition=>[{:class=>String, :id=>message.object_id,
                                                                           :composition=>"test"}],
                                                           :params_types=>[[:req, :message]]})

    end

  end

  describe "Object#_deconstruct_to_ruby" do
    it "generates the ruby code to create an object" do
      output = Pretentious.watch {
        a = "Some type of string"
        a._deconstruct_to_ruby
      }
      expect(output).to eq("a = \"Some type of string\"\n")
    end

    it "deconstruct multiple objects" do
      output = Pretentious.watch {
        a = "Some type of string"
        b = TestClass1.new("Hello world")
        test_class = TestClass3.new(a, b)
        test_class._deconstruct_to_ruby
      }
      expect(output).to eq("testclass2 = TestClass1.new(\"Hello world\")\ntest_class = TestClass3.new(\"Some type of string\", testclass2)\n")
    end
  end

  describe "#deconstruct" do

    it "should build list of variables to declare" do
      message = "test"
      another_object = Pretentious.watch {
        TestClass1.new(message)
      }

      decons = @fixture.deconstruct([], another_object)
      expect( decons ).to eq({declaration:
                                  [{id: message.object_id,
                                    class: String,
                                    value: "test",
                                    :used_by=>:inline},
                                   {id: another_object.object_id,
                                    class: TestClass1,
                                    params_types: [[:req, :message]],
                                    used_by: [], ref: [{:id=>message.object_id,
                                    :class=>String, value: "test", used_by: :inline}]}],
                              dependency: {message.object_id=>{:id=>message.object_id,
                                                               class: String, value: "test", used_by: :inline},
                                           another_object.object_id=>{id: another_object.object_id,
                                                                      :class=>TestClass1,
                                                                      :params_types=>[[:req, :message]],
                                                                      :used_by=>[],
                                                                      :ref=>[{:id=>message.object_id,
                                                                              :class=>String, :value=>"test", :used_by=>:inline}]}}})
    end

  end

end
