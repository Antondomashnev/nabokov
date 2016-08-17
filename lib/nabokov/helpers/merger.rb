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
      proceed_option = ui.ask_with_answers("Would you like to resolve the conflicts manually or abort the synchronization?\n", ["Resolve", "Abort"])
      if proceed_option == "Abort"
        MergerResult::ABORTED
      end
    end

    def ui
      @informator
    end
  end
end
