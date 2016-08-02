require 'nabokov/commands/runner'

describe Nabokov::Runner do
  it 'has the correct version' do
    expect(Nabokov::Runner.version).to eq(Nabokov::VERSION)
  end
end
