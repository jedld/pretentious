require 'spec_helper'

RSpec.describe TestClass4 do

  context 'Scenario 1' do
    before do

      var_2166230260 = "test"
      var_2166098260 = Proc.new { 
            "test"
      }


      @fixture = TestClass4.new &var_2166098260

    end

    it 'should pass current expectations' do

    end
  end

end
