require 'nabokov/helpers/merger'
require 'git'

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
      @merger = Nabokov::Merger.new(@informator, @git_repo)
    end

    context "when there are no conflicts" do
      it "succeeds" do
        allow(@git_repo).to receive(:merge_branches).with("master", "synchronization")
        expect(@merger.merge("master", "synchronization")).to eql(Nabokov::MergerResult::SUCCEEDED)
      end
    end

    context "when there are conflicts" do
      before do
        allow(@git_repo).to receive(:merge_branches).with("master", "synchronization").and_raise(Git::GitExecuteError.new("conflicts!!!"))
        allow(@informator).to receive(:error).with(anything)
        allow(@informator).to receive(:ask_with_answers).with(anything, anything)
      end

      it "shows error" do
        expect(@informator).to receive(:error).with("Merge failed with conflicts. Nabokov needs your help to continue")
        @merger.merge("master", "synchronization")
      end

      it "asks question how to proceed" do
        expect(@informator).to receive(:ask_with_answers).with("Would you like to resolve the conflicts manually or abort the synchronization?\n", ["Resolve", "Abort"])
        @merger.merge("master", "synchronization")
      end

      context "when user wants to abort the merge" do
        before do
          allow(@informator).to receive(:ask_with_answers).with("Would you like to resolve the conflicts manually or abort the synchronization?\n", ["Resolve", "Abort"]).and_return("Abort")
          allow(@git_repo).to receive(:abort_merge)
        end

        it "aborts" do
          expect(@merger.merge("master", "synchronization")).to eql(Nabokov::MergerResult::ABORTED)
        end

        it "aborts merge in the repo" do
          expect(@git_repo).to receive(:abort_merge)
          @merger.merge("master", "synchronization")
        end
      end

      context "when user wants to resolve the merge conflicts" do
        before do
          allow(@informator).to receive(:say)
          allow(@informator).to receive(:wait_for_return)
          allow(@informator).to receive(:ask_with_answers).with("Would you like to resolve the conflicts manually or abort the synchronization?\n", ["Resolve", "Abort"]).and_return("Resolve")
          allow(@git_repo).to receive(:unmerged_files).and_return(["file1.txt", "file2.txt"])
        end

        it "succeeds" do
          expect(@merger.merge("master", "synchronization")).to eql(Nabokov::MergerResult::SUCCEEDED)
        end

        it "shows the unmerged files pathes" do
          expect(@informator).to receive(:say).with("Great! Please resolve conflict in the following files:")
          expect(@informator).to receive(:say).with("* file1.txt")
          expect(@informator).to receive(:say).with("* file2.txt")
          expect(@informator).to receive(:say).with("Please press return when you're ready to move on...")
          @merger.merge("master", "synchronization")
        end
      end
    end
  end
end
