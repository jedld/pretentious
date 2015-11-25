require 'spec_helper'

RSpec.describe TestClass2 do

  context 'Scenario 1' do
    before do


      @fixture = TestClass2.new("This is message 2")

    end

    it 'should pass current expectations' do

      # TestClass2#print_message  should return 
      expect( @fixture.print_message ).to be_nil

      # TestClass2#print_message  should return 
      expect( @fixture.print_message ).to be_nil

    end
  end

end
