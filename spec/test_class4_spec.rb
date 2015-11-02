require 'spec_helper'

RSpec.describe TestClass4 do

  context 'Scenario 1' do
    before do

      var_2165841820 = "test"
      var_2165763920 = Proc.new { 
            "test"
      }


      @fixture = TestClass4.new &var_2165763920

    end

    it 'should pass current expectations' do


    end
  end

end
