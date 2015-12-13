require 'spec_helper'

RSpec.describe Pretentious::LazyTrigger do
  it 'Can predeclare even if the class is not yet defined' do
    Pretentious.watch do
      lazy_trigger = Pretentious::LazyTrigger.new('TestLazyClass')

      class TestLazyClass
        def test_method
        end
      end

      lazy_class = TestLazyClass.new
      lazy_class.test_method

      expect(lazy_trigger.instances).to eq([lazy_class])
      lazy_trigger.disable!
    end
  end
end
