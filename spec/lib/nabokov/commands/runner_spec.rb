require 'nabokov/commands/runner'

describe Nabokov::Runner do

  it 'raises an error if nabokovfile parameter is nil' do
      allow(STDOUT).to receive(:puts) # this disables puts
      expect { Nabokov::Runner.run([]) }.to raise_error("nabokovfile is a required parameter and could not be nil")
  end

  it 'raises an error when no Nabokovfile found' do
      allow(STDOUT).to receive(:puts) # this disables puts
      expect { Nabokov::Runner.run(['--nabokovfile=spec/fixtures/not_existed_file']) }.to raise_error SystemExit
  end

end
