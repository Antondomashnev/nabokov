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
        expect { @git_repo.checkout_branch("temp") }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before checkouting any branch")
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

  describe "delete_branch" do
    before do
      @git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/test_git_repo_add")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.delete_branch("temp") }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before deleting any branch")
      end
    end

    context "when git repo is initialized" do
      before do
        @underlying_git_repo = object_double(Git.init('spec/fixtures/test_git_repo_add'))
        @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git', "spec/fixtures/test_git_repo_add", @underlying_git_repo)
      end

      context "when branch name parameter is passed" do
        it "deletes a branch with the given name" do
          git_branch = object_double(Git::Branch.new('temp_branch', 'temp_branch'))
          allow(git_branch).to receive(:delete)
          expect(@underlying_git_repo).to receive(:branch).with("temp_branch").and_return(git_branch)
          @git_repo.delete_branch("temp_branch")
        end
      end

      context "when branch name parameter is zero length string" do
        it "raises an error" do
          expect { @git_repo.delete_branch("") }.to raise_error("branch name could not be nil or zero length")
        end
      end
    end
  end

  describe "merge_branches" do
    before do
      @git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/test_git_repo_add")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.merge_branches("temp1", "temp2") }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before merging any branches")
      end
    end

    context "when git repo is initialized" do
      before do
        @underlying_git_repo = object_double(Git.init('spec/fixtures/test_git_repo_add'))
        @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git', "spec/fixtures/test_git_repo_add", @underlying_git_repo)
      end

      context "when branch name parameters are passed" do
        it "merges a branch to be merged into original branch" do
          git_original_branch = object_double(Git::Branch.new('branch1', 'branch1'))
          git_branch_to_be_merged = object_double(Git::Branch.new('branch2', 'branch2'))
          allow(git_original_branch).to receive(:merge).with(git_branch_to_be_merged)
          expect(@underlying_git_repo).to receive(:branch).with("branch1").and_return(git_original_branch)
          expect(@underlying_git_repo).to receive(:branch).with("branch2").and_return(git_branch_to_be_merged)
          @git_repo.merge_branches("branch1", "branch2")
        end
      end

      context "when original branch name parameter is zero length string" do
        it "raises an error" do
          expect { @git_repo.merge_branches("", "branch2") }.to raise_error("original branch name could not be nil or zero length")
        end
      end

      context "when branch to be merged name parameter is zero length string" do
        it "raises an error" do
          expect { @git_repo.merge_branches("branch1", "") }.to raise_error("branch to be merged in name could not be nil or zero length")
        end
      end
    end
  end

  describe "has_changes" do
    before do
      @git_repo = Nabokov::GitRepo.new(@remote_url, "spec/fixtures/test_git_repo_has_changes")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.has_changes }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before checking if the git repo has changes")
      end
    end

    context "when git repo is initialized" do
      before do
        @underlying_git_repo = Git.init('spec/fixtures/test_git_repo_has_changes')
        @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git', "spec/fixtures/test_git_repo_has_changes", @underlying_git_repo)
      end

      context "when the repo has added files" do
        before do
          added_file = object_double(Git::Status::StatusFile.new("base", {}))
          allow_any_instance_of(Git::Status).to receive(:added).and_return({:path => "a", :file => added_file})
          allow_any_instance_of(Git::Status).to receive(:changed).and_return([])
          allow_any_instance_of(Git::Status).to receive(:deleted).and_return([])
        end

        it "returns true" do
          expect(@git_repo.has_changes).to be_truthy
        end
      end

      context "when the repo has deleted files" do
        before do
          deleted_file = object_double(Git::Status::StatusFile.new("base", {}))
          allow_any_instance_of(Git::Status).to receive(:deleted).and_return({:path => "a", :file => deleted_file})
          allow_any_instance_of(Git::Status).to receive(:changed).and_return([])
          allow_any_instance_of(Git::Status).to receive(:added).and_return([])
        end

        it "returns true" do
          expect(@git_repo.has_changes).to be_truthy
        end
      end

      context "when the repo has changed files" do
        before do
          changed_file = object_double(Git::Status::StatusFile.new("base", {}))
          allow_any_instance_of(Git::Status).to receive(:changed).and_return({:path => "a", :file => changed_file})
          allow_any_instance_of(Git::Status).to receive(:deleted).and_return([])
          allow_any_instance_of(Git::Status).to receive(:added).and_return([])
        end

        it "returns true" do
          expect(@git_repo.has_changes).to be_truthy
        end
      end

      context "when the repo has no changed, added and deleted files" do
        before do
          allow_any_instance_of(Git::Status).to receive(:changed).and_return([])
          allow_any_instance_of(Git::Status).to receive(:deleted).and_return([])
          allow_any_instance_of(Git::Status).to receive(:added).and_return([])
        end

        it "returns false" do
          expect(@git_repo.has_changes).to be_falsy
        end
      end
    end
  end
end
