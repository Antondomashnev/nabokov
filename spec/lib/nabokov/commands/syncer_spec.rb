require 'nabokov/commands/syncers/syncer'

describe Nabokov::Syncer do
  before(:each) do
    allow(STDOUT).to receive(:puts)
  end

  it 'is an abstract command' do
    expect(Nabokov::Syncer.abstract_command).to be_truthy
  end

  context "when --nabokovfile parameter is not passed" do
    it "raises an error" do
      expect { Nabokov::Syncer.run([]) }.to raise_error("--nabokovfile is a required parameter and could not be nil")
    end
  end

  context "when nabokovfile doesn't exist at the given path" do
    it "raises a runtime error" do
      expect { Nabokov::Syncer.run(['--nabokovfile=spec/blabla']) }.to raise_error(SystemExit)
    end
  end
end
