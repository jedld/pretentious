require 'spec_helper'

RSpec.describe Pretentious::Deconstructor do
  before do
    @fixture = Pretentious::Deconstructor.new
  end

  describe "#build_tree" do
    it "should decompose an object" do
      message = 'test'
      another_object = Pretentious.watch {
        TestClass1.new(message)
      }

      # Pretentious::Deconstructor#build_tree when passed target_object = #<TestClass1:0x00000102d82860> should return {:class=>TestClass1, :id=>2171343920, :composition=>[{:class=>String, :id=>2171343600, :composition=>"test"}]}
      expect(@fixture.build_tree(another_object)).to eq(class: TestClass1,
                                                        id: another_object.object_id,
                                                        composition: [{ class: String,
                                                                        id: message.object_id,
                                                                        composition: "test"}],
                                                        params_types: [[:req, :message]])

    end

    context "Special 'native' objects like File" do
      it "Decomposes properly" do
        file = nil
        filename = nil
        another_object = Pretentious.watch {
          filename = "example.rb"
          file = File.new(filename)
          TestClass1.new(file)
        }
        result = @fixture.build_tree(another_object)
        result[:composition][0][:composition][0][:id] = filename.object_id

        expect(result)
          .to eq(
            class: TestClass1,
            id: another_object.object_id,
            composition: [
              { class: File,
                id: file.object_id,
                composition: [
                  {
                    class: String,
                    id: filename.object_id,
                    composition: 'example.rb'
                  }]
                }],
            params_types: [[:req, :message]])
      end
    end
  end

  describe "Object#_deconstruct_to_ruby" do
    it "generates the ruby code to create an object" do
      output = Pretentious.watch do
        a = "Some type of string"
        a._deconstruct_to_ruby
      end
      expect(output).to eq("a = 'Some type of string'\n")
    end

    it "deconstructs arrays types" do
      output = Pretentious.watch do
        hash = { message: "hello" }
        arr = [1, 2, 3, "hello", hash, ['subarray', 2, :symbol]]
        test_class = TestClass1.new(arr)
        test_class._deconstruct_to_ruby
      end
      expect(output).to eq("message = [1, 2, 3, 'hello', { message: 'hello' }, ['subarray', 2, :symbol]]\ntest_class = TestClass1.new(message)\n")
    end

    it "deconstructs 'native' types" do
      file = nil
      filename = nil
      another_object = Pretentious.watch do
        filename = "example.rb"
        file = File.new(filename)
        test_class = TestClass1.new(file)
        test_class._deconstruct_to_ruby
      end
      expect(another_object).to eq("message = File.new('example.rb')\ntest_class = TestClass1.new(message)\n")
    end

    it "has special handling for unresolvable types" do
      # objects outside of the watch scope
      a = "Some type of string"
      b = TestClass1.new("Hello world")
      output = Pretentious.watch do
        test_class = TestClass3.new(a, b)
        test_class._deconstruct_to_ruby
      end
      expect(output).to eq("a = TestClass1.new # parameters unresolvable. The watcher needs to be installed before this object is created\ntestclass2 = TestClass1.new(a)\ntest_class = TestClass3.new('Some type of string', testclass2)\n")
    end

    it "deconstructs hash types" do
      output = Pretentious.watch do
        hash = { message: "hello", arr: [1, 2, 3], hash: { message2: "msg" } }
        test_class = TestClass1.new(hash)
        test_class._deconstruct_to_ruby
      end
      expect(output).to eq("message = { message: 'hello', arr: [1, 2, 3], hash: { message2: 'msg' } }\ntest_class = TestClass1.new(message)\n")
    end

    it "deconstruct multiple objects" do
      output = Pretentious.watch do
        a = "Some type of string"
        b = TestClass1.new("Hello world")
        test_class = TestClass3.new(a, b)
        test_class._deconstruct_to_ruby
      end
      expect(output).to eq("testclass2 = TestClass1.new('Hello world')\ntest_class = TestClass3.new('Some type of string', testclass2)\n")
    end
  end

  describe "#deconstruct" do
    it "should build list of variables to declare" do
      message = "test"
      another_object = Pretentious.watch do
        TestClass1.new(message)
      end

      decons = @fixture.deconstruct([], another_object)
      expect(decons).to eq({declaration:
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
