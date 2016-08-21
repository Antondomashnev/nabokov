require 'nabokov/git/git_repo'
require 'nabokov/helpers/informator'

module Nabokov
  class MergerResult
    SUCCEEDED = "succeeded"
    ABORTED = "aborted"
  end

  class Merger
    def initialize(informator, git_repo)
      raise "'informator' is a required parameter" if informator.nil?
      raise "'git_repo' is a required parameter" if git_repo.nil?
      @git_repo = git_repo
      @informator = informator
    end

    def merge(head, branch)
      begin
        @git_repo.merge_branches(head, branch)
        MergerResult::SUCCEEDED
      rescue Git::GitExecuteError => e
        rescue_merge
      end
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
      MergerResult::ABORTED
    end

    def resolve_merge
      ui.say("Great! Please resolve conflict in the following files:")
      unmerged_files = @git_repo.unmerged_files
      unmerged_files.each do |file|
        ui.say("* #{file}")
      end
      ui.say("Please press return when you're ready to move on...")
      ui.wait_for_return
      commit_after_merge_resolving(unmerged_files)
      MergerResult::SUCCEEDED
    end

    def commit_after_merge_resolving(merged_files)
      commit_merge = proc do
        merged_files.each do |file|
          ui.say("Adding #{file} to git index...")
          @git_repo.add(file)
        end
        ui.say("Commiting merge conflicts resolving...")
        @git_repo.commit("Nabokov merge conflicts manually have been resolved...")
      end

      if @git_repo.has_changes?
        ui.warn("Seems like you haven't resolved the merge, if you want to continue anyway please press return...")
        ui.wait_for_return
        commit_merge.call if @git_repo.has_changes?
      else
        commit_merge.call
      end
    end

    def ui
      @informator
    end
  end
end
