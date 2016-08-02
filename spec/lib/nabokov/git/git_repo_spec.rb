require 'nabokov/git/git_repo'
require 'git'

describe Nabokov::GitRepo do

  before do
    @remote_url = "https://github.com/Antondomashnev/nabokov_example.git"
  end

  describe "initialization" do
    it "stores remote url after initialization" do
      git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/bla")
      expect(git_repo.remote_url).to eql(@remote_url)
    end

    it "stores local path after initialization" do
      git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/bla")
      expect(git_repo.local_path).to eql("spec/fixtures/bla")
    end
  end

  describe "clone" do

    context "when there is a repo at the given local path" do
      before do
        @git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/test_git_repo_add")
      end

      it "raises an error to use init method instead" do
        expect { @git_repo.clone }.to raise_error("Git repo has been already cloned at 'spec/fixtures/test_git_repo_add', please use 'init' instead")
      end
    end

    context "when there is no repo at the given local path" do
      before do
        @git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/test_git_clone")
      end

      it "clones the repo from the correct remote" do
        allow(Git).to receive(:clone).with(@remote_url, anything, anything)
        @git_repo.clone
      end

      it "clones the repo with the correct localname" do
        allow(Git).to receive(:clone).with(anything, "test_git_clone", anything)
        @git_repo.clone
        FileUtils.rm_rf(Dir.glob("spec/fixtures/test_git_clone"))
      end

      it "clones the repo with the correct local directory path" do
        allow(Git).to receive(:clone).with(anything, anything, {path: "spec/fixtures"})
        @git_repo.clone
        FileUtils.rm_rf(Dir.glob("spec/fixtures/test_git_clone"))
      end
    end

  end

  describe "add" do
    before do
      @git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/test_git_repo_add")
    end

    context "when there is not file to add at the given path" do
      it "raises an error" do
        expect { @git_repo.add("spec/fixtures/qq.strings") }.to raise_error("Could not find any file to add at path 'spec/fixtures/qq.strings'")
      end
    end

    context "when there is a file to add" do
      context "when git repo has not been initialized yet" do
        it "raises an error" do
          expect { @git_repo.add("spec/fixtures/de.strings") }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before adding new files to the index")
        end
      end

      context "when git repo has been initialized" do
        it "adds file at the given path to the git repo index" do
          underlying_git_repo = object_double(Git.init('spec/fixtures/test_git_repo_add'))
          expect(underlying_git_repo).to receive(:add).with("spec/fixtures/test_git_repo_add/fr.strings")
          @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git', "spec/fixtures/test_git_repo_add", underlying_git_repo)
          @git_repo.add("spec/fixtures/test_git_repo_add/fr.strings")
        end
      end
    end
  end

  describe "commit" do
    before do
      @git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/test_git_repo_add")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.commit }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before commiting new files")
      end
    end

    context "when git repo has been initialized" do
      it "makes a commit with correct message" do
        underlying_git_repo = object_double(Git.init('spec/fixtures/test_git_repo_add'))
        expect(underlying_git_repo).to receive(:commit).with("Automatic commit by nabokov")
        @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git', "spec/fixtures/test_git_repo_add", underlying_git_repo)
        @git_repo.commit
      end
    end
  end

  describe "push" do
    before do
      @git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/test_git_repo_add")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.push }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before pushing any changes to remote")
      end
    end

    context "when git repo has been initialized" do
      it "makes a push to the remote" do
        underlying_git_repo = object_double(Git.init('spec/fixtures/test_git_repo_add'))
        expect(underlying_git_repo).to receive(:push)
        @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git', "spec/fixtures/test_git_repo_add", underlying_git_repo)
        @git_repo.push
      end
    end
  end

  describe "pull" do
    before do
      @git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/test_git_repo_add")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.pull }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before pushing any changes to remote")
      end
    end

    context "when git repo has been initialized" do
      it "makes a pull from the remote" do
        underlying_git_repo = object_double(Git.init('spec/fixtures/test_git_repo_add'))
        expect(underlying_git_repo).to receive(:pull)
        @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git', "spec/fixtures/test_git_repo_add", underlying_git_repo)
        @git_repo.pull
      end
    end
  end

  describe "checkout_branch" do
    before do
      @git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/test_git_repo_add")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.checkout_branch("temp") }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before pushing any changes to remote")
      end
    end

    context "when git repo is initialized" do
      before do
        @underlying_git_repo = object_double(Git.init('spec/fixtures/test_git_repo_add'))
        @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git', "spec/fixtures/test_git_repo_add", @underlying_git_repo)
      end

      context "when branch name parameter is passed" do
        it "creates a branch with the given name" do
          git_branch = object_double(Git::Branch.new('temp_branch', 'temp_branch'))
          allow(git_branch).to receive(:checkout)
          expect(@underlying_git_repo).to receive(:branch).with("temp_branch").and_return(git_branch)
          @git_repo.checkout_branch("temp_branch")
        end

        it "checkouts the given branch" do
          git_branch = object_double(Git::Branch.new('temp_branch', 'temp_branch'))
          allow(@underlying_git_repo).to receive(:branch).with(anything).and_return(git_branch)
          expect(git_branch).to receive(:checkout)
          @git_repo.checkout_branch("temp_branch")
        end
      end

      context "when branch name parameter is zero length string" do
        it "raises an error" do
          expect { @git_repo.checkout_branch("") }.to raise_error("branch name could not be nil or zero length")
        end
      end
    end
  end

end
