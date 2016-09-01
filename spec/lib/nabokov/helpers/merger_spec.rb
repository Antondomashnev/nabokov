require "nabokov/helpers/merger"
require "git"

describe Nabokov::Merger do
  describe "initialize" do
    context "when informator is nil" do
      it "raises an error" do
        git_repo = double(Nabokov::GitRepo)
        expect { Nabokov::Merger.new(nil, git_repo) }.to raise_error("'informator' is a required parameter")
      end
    end

    context "when git_repo is nil" do
      it "raises an error" do
        informator = double(Nabokov::Informator)
        expect { Nabokov::Merger.new(informator, nil) }.to raise_error("'git_repo' is a required parameter")
      end
    end
  end

  describe "merge" do
    before do
      @informator = double(Nabokov::Informator)
      @git_repo = double(Nabokov::GitRepo)
      allow(@git_repo).to receive(:local_path).and_return("nabokov/temporary_git_repo")
      @merger = Nabokov::Merger.new(@informator, @git_repo, "1234567890")
    end

    context "when there are no conflicts" do
      it "succeeds" do
        allow(@git_repo).to receive(:merge_branches).with("master", "synchronization")
        expect(@merger.merge("master", "synchronization")).to eql(Nabokov::MergerResult::SUCCEEDED)
      end
    end

    context "when there are conflicts" do
      before do
        allow(@git_repo).to receive(:changes?)
        allow(@git_repo).to receive(:merge_branches).with("master", "synchronization").and_raise(Git::GitExecuteError.new("conflicts!!!"))
        allow(@informator).to receive(:error).with(anything)
        allow(@informator).to receive(:ask_with_answers).with(anything, anything)
      end

      it "shows error" do
        expect(@informator).to receive(:error).with("Merge failed with conflicts. Nabokov needs your help to continue")
        @merger.merge("master", "synchronization")
      end

      it "asks question how to proceed" do
        expect(@informator).to receive(:ask_with_answers).with("Would you like to resolve the conflicts manually or abort the synchronization?\n", ["resolve", "abort"])
        @merger.merge("master", "synchronization")
      end

      context "when user wants to abort the merge" do
        before do
          allow(@informator).to receive(:ask_with_answers).with("Would you like to resolve the conflicts manually or abort the synchronization?\n", ["resolve", "abort"]).and_return("abort")
          allow(@git_repo).to receive(:abort_merge)
          allow(@git_repo).to receive(:reset_to_commit).with(anything, anything)
        end

        it "aborts" do
          expect(@merger.merge("master", "synchronization")).to eql(Nabokov::MergerResult::ABORTED)
        end

        it "aborts merge in the repo" do
          expect(@git_repo).to receive(:abort_merge)
          @merger.merge("master", "synchronization")
        end

        it "resets the HEAD to last commit" do
          expect(@git_repo).to receive(:reset_to_commit).with("1234567890", { hard: true })
          @merger.merge("master", "synchronization")
        end
      end

      context "when user wants to resolve the merge conflicts" do
        before do
          allow(@informator).to receive(:say)
          allow(@informator).to receive(:warn)
          allow(@informator).to receive(:wait_for_return)
          allow(@informator).to receive(:ask_with_answers).with("Would you like to resolve the conflicts manually or abort the synchronization?\n", ["resolve", "abort"]).and_return("resolve")
          allow(@git_repo).to receive(:unmerged_files).and_return(["file1.txt", "file2.txt"])
          allow(@git_repo).to receive(:add).with(anything)
          allow(@git_repo).to receive(:commit).with(anything)
          allow(@git_repo).to receive(:changes?).and_return(true)
        end

        it "succeeds" do
          expect(@merger.merge("master", "synchronization")).to eql(Nabokov::MergerResult::SUCCEEDED)
        end

        it "shows the unmerged files pathes" do
          expect(@informator).to receive(:say).with("Great! Please resolve conflict in the following files:")
          expect(@informator).to receive(:say).with("* nabokov/temporary_git_repo/file1.txt")
          expect(@informator).to receive(:say).with("* nabokov/temporary_git_repo/file2.txt")
          expect(@informator).to receive(:say).with("Please press return when you're ready to move on...")
          expect(@informator).to receive(:wait_for_return)
          @merger.merge("master", "synchronization")
        end

        it "adds merged files to index" do
          expect(@git_repo).to receive(:add).with("nabokov/temporary_git_repo/file1.txt")
          expect(@git_repo).to receive(:add).with("nabokov/temporary_git_repo/file2.txt")
          @merger.merge("master", "synchronization")
        end

        it "commits merge files" do
          expect(@git_repo).to receive(:commit).with("Nabokov merge conflicts manually have been resolved...")
          @merger.merge("master", "synchronization")
        end
      end
    end
  end
end
