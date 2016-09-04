require "nabokov/git/git_repo"
require "nabokov/helpers/informator"

module Nabokov
  # Result of the merge action perfomed by Nabokov::Merger
  class MergerResult
    SUCCEEDED = "succeeded".freeze
    ABORTED = "aborted".freeze
  end

  # Class is responsible for merging two branches
  class Merger
    def initialize(informator, git_repo, rescue_commit_sha = nil)
      raise "'informator' is a required parameter" if informator.nil?
      raise "'git_repo' is a required parameter" if git_repo.nil?
      @rescue_commit_sha = rescue_commit_sha
      @git_repo = git_repo
      @informator = informator
    end

    # Merges one branch with another branch
    # It handles the situation when there are merge conflicts and provides
    #    the interface to the user to resolve the conflicts
    def merge(head, branch)
      @git_repo.merge_branches(head, branch)
      MergerResult::SUCCEEDED
    rescue Git::GitExecuteError
      rescue_merge
    end

    private

    def rescue_merge
      ui.error("Merge failed with conflicts. Nabokov needs your help to continue")
      proceed_option = ui.ask_with_answers("Would you like to resolve the conflicts manually or abort the synchronization?\n", ["resolve", "abort"])
      if proceed_option == "abort"
        abort_merge
      elsif proceed_option == "resolve"
        resolve_merge
      end
    end

    def abort_merge
      @git_repo.abort_merge
      @git_repo.reset_to_commit(@rescue_commit_sha, { hard: true }) unless @rescue_commit_sha.nil?
      MergerResult::ABORTED
    end

    def resolve_merge
      ui.say("Great! Please resolve conflict in the following files:")
      unmerged_files = @git_repo.unmerged_files
      unmerged_files.each do |file|
        file_path = @git_repo.local_path + "/" + file
        ui.say("* #{file_path}")
      end
      ui.say("Please press return when you're ready to move on...")
      ui.wait_for_return
      commit_after_merge_resolving(unmerged_files)
      MergerResult::SUCCEEDED
    end

    def commit_after_merge_resolving(merged_files)
      commit_merge = proc do
        merged_files.each do |file|
          file_path = @git_repo.local_path + "/" + file
          ui.say("Adding #{file_path} to git index...")
          @git_repo.add(file_path)
        end
        ui.say("Commiting merge conflicts resolving...")
        @git_repo.commit("Nabokov merge conflicts manually have been resolved...")
      end

      if @git_repo.changes?
        commit_merge.call
      else
        ui.warn("Seems like you haven't resolved the merge, if you want to continue anyway please press return...")
        ui.wait_for_return
        commit_merge.call if @git_repo.changes?
      end
    end

    def ui
      @informator
    end
  end
end
