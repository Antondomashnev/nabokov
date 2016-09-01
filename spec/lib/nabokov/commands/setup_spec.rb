require "nabokov/commands/setup"
require "fileutils"
require "git"

describe Nabokov::Setup do
  describe "run" do
    before(:all) do
      FileUtils.mkdir_p("spec/fixtures/test_git_setup/git_folder")
      Git.init("spec/fixtures/test_git_setup/git_folder")
    end

    before(:each) do
      allow(STDOUT).to receive(:puts)
    end

    context "when pre_commit_file path is a file" do
      it "uses the given path" do
        setup = Nabokov::Setup.run(["--pre_commit_file=spec/fixtures/test_git_setup/existed_pre_commit_file", "--git_path=spec/fixtures/test_git_setup"])
        expect(setup.pre_commit_file).to eql("spec/fixtures/test_git_setup/existed_pre_commit_file")
      end
    end

    context "when pre_commit_file path is a symlink" do
      it "uses the real path" do
        setup = Nabokov::Setup.run(["--pre_commit_file=spec/fixtures/test_git_setup/existed_pre_commit_file_alias", "--git_path=spec/fixtures/test_git_setup"])
        expect(setup.pre_commit_file).to end_with("spec/fixtures/test_git_setup/existed_pre_commit_file")
      end
    end

    context "when pre_commit_file doesn't exist" do
      context "when the given git_path there is no folder" do
        it "raises an exception" do
          expect { Nabokov::Setup.run(["--pre_commit_file=spec/fixtures/test_git_setup/missing_file", "--git_path=spec/fixtures/test_git_setup_fake"]) }.to raise_error(".git folder is not found at 'spec/fixtures/test_git_setup_fake'")
        end
      end

      it "creates a pre_commit_file at the given git_path/hooks/pre_commit" do
        setup = Nabokov::Setup.run(["--pre_commit_file=spec/fixtures/test_git_setup/missing_file", "--git_path=spec/fixtures/test_git_setup/git_folder/.git"])
        expect(File.exist?(setup.pre_commit_file)).to be_truthy
        FileUtils.rm_rf(Dir.glob("spec/fixtures/test_git_setup/git_folder/.git/*"))
      end
    end

    context "when pre_commit_file is not executable" do
      it "raises an exception" do
        input = ["--pre_commit_file=spec/fixtures/test_git_setup/not_executable_pre_commit_file", "--git_path=spec/fixtures/test_git_setup/git_folder/.git"]
        expect { Nabokov::Setup.run(input) }.to raise_error("pre commit file at 'spec/fixtures/test_git_setup/not_executable_pre_commit_file' is not executable by the effective user id of this process")
      end
    end

    context "when current git repo is not listed in pre_commit_file" do
      before(:each) do
        input = ["--pre_commit_file=spec/fixtures/test_git_setup/existed_pre_commit_file", "--git_path=spec/fixtures/test_git_setup/git_folder/.git"]
        Nabokov::Setup.run(input)
      end

      after(:each) do
        File.truncate("spec/fixtures/test_git_setup/existed_pre_commit_file", 0)
      end

      it "puts into pre commit line to tell that file is executable" do
        result = File.foreach("spec/fixtures/test_git_setup/existed_pre_commit_file").any? do |line|
          line.include?("#!\/usr\/bin\/env bash")
        end
        expect(result).to be_truthy
      end

      it "puts into pre commit line about current repo path" do
        result = File.foreach("spec/fixtures/test_git_setup/existed_pre_commit_file").any? do |line|
          line.include?("current_repo_path=\$(git rev-parse --show-toplevel)")
        end
        expect(result).to be_truthy
      end

      it "puts into pre commit line about nabokovfile path" do
        result = File.foreach("spec/fixtures/test_git_setup/existed_pre_commit_file").any? do |line|
          line.include?("nabokovfile_path=\"$current_repo_path\/Nabokovfile\"")
        end
        expect(result).to be_truthy
      end

      it "puts into pre commit line about tracking repo path" do
        result = File.foreach("spec/fixtures/test_git_setup/existed_pre_commit_file").any? do |line|
          line.include?("tracking_repo_path=")
        end
        expect(result).to be_truthy
      end

      it "puts into pre commit line to exectute nabokov" do
        result = File.foreach("spec/fixtures/test_git_setup/existed_pre_commit_file").any? do |line|
          line.include?("if [ \"$current_repo_path\" == \"$tracking_repo_path\" ] && gem list -i nabokov && [ -e \"$nabokovfile_path\" ]; then nabokov --nabokovfile=$nabokovfile_path || exit 1; fi")
        end
        expect(result).to be_truthy
      end
    end
  end
end
