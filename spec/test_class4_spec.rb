require 'spec_helper'

RSpec.describe TestClass4 do

  context 'Scenario 1' do
    before do

      var_2194392760 = "test"
      var_2194280000 = Proc.new { 
            "test"
      }


      @fixture = TestClass4.new &var_2194280000

    end

    it 'should pass current expectations' do


    end
  end

end
