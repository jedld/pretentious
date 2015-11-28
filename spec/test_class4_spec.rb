require 'spec_helper'

RSpec.describe TestClass4 do

  context 'Scenario 1' do
    before do

      var_2157436060 = "test"
      var_2157471500 = Proc.new { 
            "test"
      }


      @fixture = TestClass4.new &var_2157471500

    end

    it 'should pass current expectations' do

    end
  end

end
