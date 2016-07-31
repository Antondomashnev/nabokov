require 'nabokov/commands/runner'

describe Nabokov::Runner do
  before do
    allow(STDOUT).to receive(:puts) # this disables puts
  end

  context "when nabokovfile parameter is nil" do
    it "raises an error" do
      expect { Nabokov::Runner.run([]) }.to raise_error("nabokovfile is a required parameter and could not be nil")
    end
  end

  context "when nabokovfile is not fount at the given path" do
    it "raises an error" do
      expect { Nabokov::Runner.run(['--nabokovfile=spec/fixtures/not_existed_file']) }.to raise_error SystemExit
    end
  end
end
