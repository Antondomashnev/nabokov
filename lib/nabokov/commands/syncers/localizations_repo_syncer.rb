require "nabokov/commands/syncers/syncer"
require "nabokov/core/file_manager"
require "nabokov/helpers/merger"

module Nabokov
  class LocalizationsRepoSyncer < Syncer
    self.abstract_command = false
    self.command = "localizations"
    self.summary = "Sync remote localizations repo with the local localization strings."

    def initialize(argv)
      super
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
      ui.inform("Nabokov has finished localizations repo synchronization")
    end

    private

    def checkout_temporary_branch
      ui.say("Checkout a temporary branch for new localization strings...")
      self.git_repo.checkout_branch(temporary_branch)
    end

    def update_localization_files
      has_changes = false
      self.nabokovfile.project_localization_file_paths.each do |localization_file_name, localization_file_path|
        ui.say("Copying strings file from '#{localization_file_path}' to the localization repo...")
        new_file_path = FileManager.copy_and_rename(localization_file_path, self.git_repo.local_path, localization_file_name.to_s)
        self.git_repo.add(new_file_path)
        if self.git_repo.changes?
          self.git_repo.commit("Nabokov localization file '#{localization_file_name}' update...")
          has_changes = true
        else
          ui.say("'#{localization_file_name}' file doesn't have any changes to commit...")
        end
      end
      has_changes
    end

    def checkout_master_branch
      ui.say("Checkout master branch...")
      self.git_repo.checkout_branch(self.nabokovfile.localizations_repo_master_branch)
      @rescue_commit_sha = self.git_repo.log(1)
    end

    def fetch_master_branch_changes
      ui.say("Fetching remote master branch changes...")
      self.git_repo.pull
    end

    def delete_temporary_branch
      ui.say("Deleting temporary branch...")
      self.git_repo.delete_branch(temporary_branch)
    end

    def push_changes_to_remote
      ui.say("Pushing changes to remote...")
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
