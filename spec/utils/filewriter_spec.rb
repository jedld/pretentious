require 'spec_helper'

describe Pretentious::FileWriter do

  before do
    Pretentious.clear_results
    Pretentious.spec_for(TestClass1) do
      message = { test: 'message' }
      object = TestClass1.new(message)
      object.return_self(message)
    end
    @last_results = Pretentious.last_results
    @instance = Pretentious::FileWriter.new({ output: 'generated'})
  end

  it 'writes the class output to a file' do
    file = double('file')
    allow(Pretentious::RspecGenerator).to receive(:helper)
    expect(File).to receive(:open).with('spec/generated/test_class1_spec.rb', 'w').and_yield(file)
    expect(file).to receive(:write).with(@last_results[:spec][TestClass1][:output])
    expect(FileUtils).to receive(:mkdir_p).with('spec')
    expect(FileUtils).to receive(:mkdir_p).with('spec/generated')

    @instance.write_results(Pretentious.last_results)
  end
end
