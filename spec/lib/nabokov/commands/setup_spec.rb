require 'nabokov/commands/setup'

describe Nabokov::Setup do

  context "run" do

    it "uses the given path to the pre_commit_file if it exists" do
      allow(STDOUT).to receive(:puts) # this disables puts
      setup = Nabokov::Setup.run(['--pre_commit_file=spec/fixtures/test_git_setup/existed_pre_commit_file', '--git_path=spec/fixtures/test_git_setup'])
      expect(setup.pre_commit_file).to eql("spec/fixtures/test_git_setup/existed_pre_commit_file")
    end

    it "uses the real path to the pre_commit_file if the given path is symlink" do
      allow(STDOUT).to receive(:puts) # this disables puts
      setup = Nabokov::Setup.run(['--pre_commit_file=spec/fixtures/test_git_setup/existed_pre_commit_file_alias', '--git_path=spec/fixtures/test_git_setup'])
      expect(setup.pre_commit_file).to end_with("spec/fixtures/test_git_setup/existed_pre_commit_file")
    end

    it "uses the real path to the pre_commit_file if the given path is symlink" do
      allow(STDOUT).to receive(:puts) # this disables puts
      setup = Nabokov::Setup.run(['--pre_commit_file=spec/fixtures/test_git_setup/existed_pre_commit_file_alias', '--git_path=spec/fixtures/test_git_setup'])
      expect(setup.pre_commit_file).to end_with("spec/fixtures/test_git_setup/existed_pre_commit_file")
    end

  end

end
