require "nabokov/commands/syncers/syncer"
require "nabokov/core/file_manager"
require "nabokov/helpers/merger"

module Nabokov
  class LocalizationsRepoSyncer < Syncer
    self.abstract_command = false
    self.command = "localizations"
    self.summary = "Synchronize remote localizations repo with the project localization strings."

    def initialize(argv)
      super
      @synchronized_file_names = []
    end

    def validate!
      super
    end

    def self.options
      super
    end

    def run
      ui.important("Nabokov starts localizations repo synchronization")
      super
      checkout_temporary_branch
      has_changes = update_localization_files
      checkout_master_branch
      fetch_master_branch_changes
      if has_changes && merge_master_branch_with_temporary(@rescue_commit_sha) == Nabokov::MergerResult::SUCCEEDED
        push_changes_to_remote
      end
      delete_temporary_branch
      notify_user_about_finish
    end

    private

    def notify_user_about_finish
      if @synchronized_file_names.count > 0
        ui.say("#{@synchronized_file_names} have been updated on remote.")
        ui.say("Your are all set.")
      else
        ui.say("Nothing to synchronize, localizations in the remote")
        ui.say("repo and project repo are the same.")
      end
      ui.important("Nabokov has finished localizations remote repo synchronization 🎉")
    end

    def checkout_temporary_branch
      ui.say("Checkout a temporary branch for new localization strings...")
      self.git_repo.checkout_branch(temporary_branch)
    end

    def update_localization_files
      has_changes = false
      self.nabokovfile.project_localization_file_paths.each do |localization_file_name, localization_file_path|
        ui.say("Copying strings file from '#{localization_file_path}' to the localization repo...") if self.verbose
        new_file_path = FileManager.copy_and_rename(localization_file_path, self.git_repo.local_path, localization_file_name.to_s)
        self.git_repo.add(new_file_path)
        if self.git_repo.changes?
          @synchronized_file_names << localization_file_name
          self.git_repo.commit("Nabokov localization file '#{localization_file_name}' update...")
          has_changes = true
        else
          ui.say("'#{localization_file_name}' file doesn't have any changes to commit...") if self.verbose
        end
      end
      has_changes
    end

    def checkout_master_branch
      ui.say("Checkout master branch...") if self.verbose
      self.git_repo.checkout_branch(self.nabokovfile.localizations_repo_master_branch)
      @rescue_commit_sha = self.git_repo.log(1)
    end

    def fetch_master_branch_changes
      ui.say("Fetching remote master branch changes...") if self.verbose
      self.git_repo.pull
    end

    def delete_temporary_branch
      ui.say("Deleting temporary branch...") if self.verbose
      self.git_repo.delete_branch(temporary_branch)
    end

    def push_changes_to_remote
      ui.say("Pushing changes to remote...") if self.verbose
      self.git_repo.push
    end

    def merge_master_branch_with_temporary(rescue_commit_sha = nil)
      merger = Merger.new(ui, self.git_repo, rescue_commit_sha)
      merger.merge(self.nabokovfile.localizations_repo_master_branch, temporary_branch)
    end

    def temporary_branch
      "nabokov/temporary_branch"
    end
  end
end
