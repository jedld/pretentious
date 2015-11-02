require 'spec_helper'

RSpec.describe TestClass4 do

  context 'Scenario 1' do
    before do

      var_2161332560 = "test"
      var_2161220900 = Proc.new { 
            "test"
      }


      @fixture = TestClass4.new &var_2161220900

    end

    it 'should pass current expectations' do


    end
  end

end
