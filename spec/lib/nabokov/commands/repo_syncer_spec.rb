require 'nabokov/commands/syncers/repo_syncer'
require 'nabokov/git/git_repo'

describe Nabokov::RepoSyncer do
  before(:each) do
    allow(STDOUT).to receive(:puts)
  end

  it 'is not an abstract command' do
    expect(Nabokov::RepoSyncer.abstract_command).to be_falsy
  end

  describe "run" do


    before(:each) do
      test_git_repo_url = "https://github.com/Antondomashnev/nabokov_example.git"
      test_git_repo_path = "spec/fixtures/test_repo_syncer"
      FileUtils.mkdir(test_git_repo_path)

      @nabokovfile = Nabokov::Nabokovfile.new("spec/fixtures/nabokovfile_example_without_master_branch.yaml")
      allow(@nabokovfile).to receive(:localizations_local_path).and_return(test_git_repo_path)
      allow(Nabokov::Nabokovfile).to receive(:new).with(anything).and_return(@nabokovfile)

      @git_repo = Nabokov::GitRepo.new(@nabokovfile.localizations_repo_url, @nabokovfile.localizations_local_path)
      allow(Nabokov::GitRepo).to receive(:new).with(anything, anything).and_return(@git_repo)
    end

    after(:each) do
      FileUtils.rm_rf(Dir.glob("spec/fixtures/test_repo_syncer"))
    end

    context "when the remote repo is empty" do
      before (:each) do
        allow(@git_repo).to receive(:push)
      end

      it "merges the localization strings files into the master branch" do
        Nabokov::RepoSyncer.run(['--nabokovfile=spec/fixtures/nabokovfile_example_without_master_branch.yaml'])
      end
    end
  end
end
