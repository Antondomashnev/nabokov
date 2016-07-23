require 'nabokov/commands/setup'

describe Nabokov::Setup do

  describe "run" do
    before do
      allow(STDOUT).to receive(:puts)
    end

    context "when pre_commit_file path is a file" do

      it "uses the given path" do
        setup = Nabokov::Setup.run(['--pre_commit_file=spec/fixtures/test_git_setup/existed_pre_commit_file', '--git_path=spec/fixtures/test_git_setup'])
        expect(setup.pre_commit_file).to eql("spec/fixtures/test_git_setup/existed_pre_commit_file")
      end

    end

    context "when pre_commit_file path is a symlink" do
      it "uses the real path" do
        setup = Nabokov::Setup.run(['--pre_commit_file=spec/fixtures/test_git_setup/existed_pre_commit_file_alias', '--git_path=spec/fixtures/test_git_setup'])
        expect(setup.pre_commit_file).to end_with("spec/fixtures/test_git_setup/existed_pre_commit_file")
      end
    end

    context "when pre_commit_file doesn't exist" do

      it "raises an exception if at the given git_path there is no folder" do
        expect { Nabokov::Setup.run(['--pre_commit_file=spec/fixtures/test_git_setup/missing_file', '--git_path=spec/fixtures/test_git_setup_fake']) }.to raise_error(".git folder is not found at 'spec/fixtures/test_git_setup_fake'")
      end

      it "creates a pre_commit_file at the given_git_path/hooks/pre_commit" do
        setup = Nabokov::Setup.run(['--pre_commit_file=spec/fixtures/test_git_setup/missing_file', '--git_path=spec/fixtures/test_git_setup/git_folder/.git'])
        expect(File.exists?(setup.pre_commit_file)).to be_truthy
        FileUtils.rm_rf(Dir.glob("spec/fixtures/test_git_setup/git_folder/.git/*"))
      end

    end
  end

end
