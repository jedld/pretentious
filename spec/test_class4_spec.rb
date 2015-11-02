require 'spec_helper'

RSpec.describe TestClass4 do

  context 'Scenario 1' do
    before do

      var_2165592540 = "test"
      var_2159747700 = Proc.new { 
            "test"
      }


      @fixture = TestClass4.new &var_2159747700

    end

    it 'should pass current expectations' do


    end
  end

end
