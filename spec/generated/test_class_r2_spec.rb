# This file was automatically generated by the pretentious gem
require 'spec_helper'

RSpec.describe TestClassR2 do
  context 'Scenario 1' do
    before do
      @fixture = TestClassR2.new
    end

    it 'should pass current expectations' do
      # TestClassR2#hello_again  should return 'hi'
      expect(@fixture.hello_again).to eq('hi')

      # TestClassR2#pass_message when passed message = "a message" should return 'a message CONST'
      expect(@fixture.pass_message('a message')).to eq('a message CONST')
    end
  end
end