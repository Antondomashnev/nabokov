require "nabokov/git/git_repo"
require "git"

describe Nabokov::GitRepo do
  before do
    @remote_url = "https://github.com/Antondomashnev/nabokov_example.git"
  end

  describe "initialization" do
    it "stores remote url after initialization" do
      git_repo = Nabokov::GitRepo.new("spec/fixtures/bla", @remote_url)
      expect(git_repo.remote_url).to eql(@remote_url)
    end

    it "stores local path after initialization" do
      git_repo = Nabokov::GitRepo.new("spec/fixtures/bla", @remote_url)
      expect(git_repo.local_path).to eql(File.expand_path("spec/fixtures/bla"))
    end
  end

  describe "clone" do
    context "when there is a repo at the given local path" do
      before do
        @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/clone")
        prepare_repo(@repo_local_path, "spec/fixtures/README.md")
        @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
      end

      after do
        FileUtils.rm_rf("spec/fixtures/test_git_repo")
      end

      it "raises an error to use init method instead" do
        expect { @git_repo.clone }.to raise_error("Git repo has been already cloned at '#{File.expand_path('spec/fixtures/test_git_repo/clone')}', please use 'init' instead")
      end
    end

    context "when there is no repo at the given local path" do
      before do
        @git_repo = Nabokov::GitRepo.new("spec/fixtures/test_git_clone", @remote_url)
      end

      it "clones the repo from the correct remote" do
        allow(Git).to receive(:clone).with(@remote_url, anything, anything)
        @git_repo.clone
      end

      it "clones the repo with the correct localname" do
        allow(Git).to receive(:clone).with(anything, "test_git_clone", anything)
        @git_repo.clone
      end

      it "clones the repo with the correct local directory path" do
        allow(Git).to receive(:clone).with(anything, anything, { path: File.expand_path("spec/fixtures") })
        @git_repo.clone
      end
    end
  end

  describe "add" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/add")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
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
        before do
          @git_repo.init
        end

        it "adds file at the given path to the git repo index" do
          FileUtils.cp_r("spec/fixtures/de.strings", @git_repo.local_path)

          @git_repo.add("#{@repo_local_path}/de.strings")

          expect(@git_repo.git_repo.status.added.count).to eql(1)
        end
      end
    end
  end

  describe "commit" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/commit")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.commit }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before commiting new files")
      end
    end

    context "when git repo has been initialized" do
      before do
        @git_repo.init
      end

      it "makes a commit with correct message" do
        FileUtils.cp_r("spec/fixtures/de.strings", @git_repo.local_path)
        @git_repo.add("#{@repo_local_path}/de.strings")

        @git_repo.commit

        expect(@git_repo.git_repo.log.first.message).to eql("Automatic commit by nabokov")
      end
    end
  end

  describe "push" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/push")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.push }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before pushing any changes to remote")
      end
    end

    context "when git repo has been initialized" do
      before do
        @git_repo.init
      end

      it "makes a push to the remote" do
        expect(@git_repo.git_repo).to receive(:push)

        @git_repo.push
      end
    end
  end

  describe "pull" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/pull")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.pull }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before pushing any changes to remote")
      end
    end

    context "when git repo has been initialized" do
      before do
        @git_repo.init
      end

      it "makes a pull from the remote" do
        expect(@git_repo.git_repo).to receive(:pull)

        @git_repo.pull
      end
    end
  end

  describe "checkout_branch" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/checkout_branch")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.checkout_branch("temp") }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before checkouting any branch")
      end
    end

    context "when git repo is initialized" do
      before do
        @git_repo.init
      end

      context "when branch name parameter is passed" do
        context "when branch exists" do
          before do
            allow(@git_repo.git_repo).to receive(:is_branch?).with("temp_branch").and_return(true)
          end

          it "checkouts the given branch" do
            expect(@git_repo.git_repo).to receive(:checkout).with("temp_branch")

            @git_repo.checkout_branch("temp_branch")
          end
        end

        context "when branch doesn't exist" do
          before do
            allow(@git_repo.git_repo).to receive(:is_branch?).with("temp_branch").and_return(false)
          end

          it "checkouts a new branch" do
            expect(@git_repo.git_repo).to receive(:checkout).with("temp_branch", { new_branch: true })

            @git_repo.checkout_branch("temp_branch")
          end
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
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/delete_branch")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.delete_branch("temp") }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before deleting any branch")
      end
    end

    context "when git repo is initialized" do
      before do
        @git_repo.init
      end

      context "when branch name parameter is passed" do
        it "deletes a branch with the given name" do
          git_branch = Git::Branch.new("temp_branch", "temp_branch")
          allow(git_branch).to receive(:delete)

          expect(@git_repo.git_repo).to receive(:branch).with("temp_branch").and_return(git_branch)

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
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/merge_branches")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.merge_branches("temp1", "temp2") }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before merging any branches")
      end
    end

    context "when git repo is initialized" do
      before do
        @git_repo.init
      end

      context "when branch name parameters are passed" do
        it "merges a branch to be merged into original branch" do
          git_original_branch = Git::Branch.new("branch1", "branch1")
          git_branch_to_be_merged = Git::Branch.new("branch2", "branch2")
          allow(git_original_branch).to receive(:merge).with(git_branch_to_be_merged)
          expect(@git_repo.git_repo).to receive(:branch).with("branch1").and_return(git_original_branch)
          expect(@git_repo.git_repo).to receive(:branch).with("branch2").and_return(git_branch_to_be_merged)
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

  describe "unfinished_merge?" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/unfinished_merge?")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.unfinished_merge? }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before checking if the git repo has unfinished merge")
      end
    end

    context "when git repo is initialized" do
      before do
        @git_repo.init
      end

      context "when git repo doesn't have unmerged files" do
        before do
          allow(@git_repo.git_repo).to receive(:has_unmerged_files?).and_return(false)
        end

        it "returns false" do
          expect(@git_repo.unfinished_merge?).to be_falsy
        end
      end

      context "when git repo has unmerged files" do
        before do
          allow(@git_repo.git_repo).to receive(:has_unmerged_files?).and_return(true)
        end

        it "returns false" do
          expect(@git_repo.unfinished_merge?).to be_truthy
        end
      end
    end
  end

  describe "abort_merge" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/abort_merge")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.abort_merge }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before aborting merge")
      end
    end

    context "when git repo is initialized" do
      before do
        @git_repo.init
      end

      context "when git repo doesn't have unfinished merge" do
        before do
          allow(@git_repo.git_repo).to receive(:has_unmerged_files?).and_return(false)
        end

        it "raises an error" do
          expect { @git_repo.abort_merge }.to raise_error("nothing to abort - git repo doesn't have unfinished merge")
        end
      end

      context "when git repo has unfinished merge" do
        before do
          allow(@git_repo.git_repo).to receive(:has_unmerged_files?).and_return(true)
        end

        it "aborts merge" do
          expect(@git_repo.git_repo).to receive(:abort_merge)

          @git_repo.abort_merge
        end
      end
    end
  end

  describe "unmerged_files" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/unmerged_files")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.unmerged_files }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before asking for unmerged files")
      end
    end

    context "when git repo is initialized" do
      before do
        @git_repo.init
      end

      context "when git repo has unfinished merge" do
        before do
          allow(@git_repo.git_repo).to receive(:has_unmerged_files?).and_return(true)
          allow(@git_repo.git_repo).to receive(:each_conflict) { |&block|
            block.call("file1.txt", "", "")
            block.call("file2.txt", "", "")
          }
        end

        it "returns unfinished file pathes" do
          expect(@git_repo.unmerged_files).to eql(["file1.txt", "file2.txt"])
        end
      end

      context "when git repo doesn't have unfinished merge" do
        before do
          allow(@git_repo.git_repo).to receive(:has_unmerged_files?).and_return(false)
        end

        it "returns empty array" do
          expect(@git_repo.unmerged_files).to eql([])
        end
      end
    end
  end

  describe "current_branch" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/current_branch")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.current_branch }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before getting the current branch")
      end
    end

    context "when git repo is initialized" do
      before do
        @git_repo.init
      end

      it "returns the current branch name" do
        allow(@git_repo.git_repo).to receive(:current_branch).and_return("develop")

        expect(@git_repo.current_branch).to eql("develop")
      end
    end
  end

  describe "log" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/log")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.log(5) }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before getting the log")
      end
    end

    context "when git repo is initialized" do
      before do
        @git_repo.init
      end

      it "returns last n commit shas" do
        commit1 = Git::Object::Commit.new("base", "1234567890", nil)
        allow(commit1).to receive(:sha).and_return("1234567890")
        commit2 = Git::Object::Commit.new("base", "1234567891", nil)
        allow(commit2).to receive(:sha).and_return("1234567891")
        commit3 = Git::Object::Commit.new("base", "1234567892", nil)
        allow(commit3).to receive(:sha).and_return("1234567892")
        commit4 = Git::Object::Commit.new("base", "1234567893", nil)
        allow(commit4).to receive(:sha).and_return("1234567893")
        commit5 = Git::Object::Commit.new("base", "1234567894", nil)
        allow(commit5).to receive(:sha).and_return("1234567894")
        allow(@git_repo.git_repo).to receive(:log).with(3).and_return([commit1, commit2, commit3])
        allow(@git_repo.git_repo).to receive(:log).with(5).and_return([commit1, commit2, commit3, commit4, commit5])

        expect(@git_repo.log(3)).to eql(["1234567890", "1234567891", "1234567892"])
        expect(@git_repo.log(5)).to eql(["1234567890", "1234567891", "1234567892", "1234567893", "1234567894"])
      end
    end
  end

  describe "reset_to_commit" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/reset_to_commit")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.reset_to_commit("1234567890") }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before resetting")
      end
    end

    context "when git repo is initialized" do
      before do
        @git_repo.init
      end

      context "when commit sha is not provided" do
        it "raises an error" do
          expect { @git_repo.reset_to_commit(nil) }.to raise_error("'commit' is a required parameter and could not be nil")
        end
      end

      context "when commit sha is provided" do
        context "when soft reset" do
          it "does soft reset" do
            expect(@git_repo.git_repo).to receive(:reset).with("1234567890")

            @git_repo.reset_to_commit("1234567890")
          end
        end

        context "when hard reset" do
          it "does hard reset" do
            expect(@git_repo.git_repo).to receive(:reset_hard).with("1234567890")

            @git_repo.reset_to_commit("1234567890", { hard: true })
          end
        end
      end
    end
  end

  describe "changes?" do
    before do
      @repo_local_path = File.expand_path("spec/fixtures/test_git_repo/changes?")
      prepare_repo(@repo_local_path, "spec/fixtures/README.md")
      @git_repo = Nabokov::GitRepo.new(@repo_local_path, @remote_url)
    end

    after do
      FileUtils.rm_rf("spec/fixtures/test_git_repo")
    end

    context "when git repo has not been initialized yet" do
      it "raises an error" do
        expect { @git_repo.changes? }.to raise_error("'git' is not initialized yet, please call either 'clone' or 'init' before checking if the git repo has changes")
      end
    end

    context "when git repo is initialized" do
      before do
        @git_repo.init
        allow_any_instance_of(Git::Status).to receive(:construct_status) {}
      end

      context "when the repo has added files" do
        before do
          added_file = object_double(Git::Status::StatusFile.new("base", {}))
          allow_any_instance_of(Git::Status).to receive(:added).and_return({ path: "a", file: added_file })
          allow_any_instance_of(Git::Status).to receive(:changed).and_return([])
          allow_any_instance_of(Git::Status).to receive(:deleted).and_return([])
        end

        it "returns true" do
          expect(@git_repo.changes?).to be_truthy
        end
      end

      context "when the repo has deleted files" do
        before do
          deleted_file = object_double(Git::Status::StatusFile.new("base", {}))
          allow_any_instance_of(Git::Status).to receive(:deleted).and_return({ path: "a", file: deleted_file })
          allow_any_instance_of(Git::Status).to receive(:changed).and_return([])
          allow_any_instance_of(Git::Status).to receive(:added).and_return([])
        end

        it "returns true" do
          expect(@git_repo.changes?).to be_truthy
        end
      end

      context "when the repo has changed files" do
        before do
          changed_file = object_double(Git::Status::StatusFile.new("base", {}))
          allow_any_instance_of(Git::Status).to receive(:changed).and_return({ path: "a", file: changed_file })
          allow_any_instance_of(Git::Status).to receive(:deleted).and_return([])
          allow_any_instance_of(Git::Status).to receive(:added).and_return([])
        end

        it "returns true" do
          expect(@git_repo.changes?).to be_truthy
        end
      end

      context "when the repo has no changed, added and deleted files" do
        before do
          allow_any_instance_of(Git::Status).to receive(:changed).and_return([])
          allow_any_instance_of(Git::Status).to receive(:deleted).and_return([])
          allow_any_instance_of(Git::Status).to receive(:added).and_return([])
        end

        it "returns false" do
          expect(@git_repo.changes?).to be_falsy
        end
      end
    end
  end
end
