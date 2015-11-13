require 'spec_helper'

RSpec.describe TestClass4 do

  context 'Scenario 1' do
    before do

      var_2167280720 = "test"
      var_2167161160 = Proc.new { 
            "test"
      }


      @fixture = TestClass4.new &var_2167161160

    end

    it 'should pass current expectations' do


    end
  end

end
