require 'nabokov/commands/syncers/syncer'
require 'nabokov/core/file_manager'

module Nabokov
  class RepoSyncer < Syncer

    self.abstract_command = false
    self.summary = 'Sync remote localizations repo with the local localization strings.'

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
      super

      ui.puts "Checkout a temporary branch for new localization strings…".green
      self.git_repo.checkout_branch(temporary_branch)

      self.nabokovfile.localization_file_paths.each do |localization_file_name, localization_file_path|
        ui.puts "Copying strings file from #{localization_file_path} to the repo…".green
        new_file_path = FileManager.copy_and_rename(localization_file_path, self.git_repo.local_path, localization_file_name.to_s)
        self.git_repo.add(new_file_path)
        self.git_repo.commit("Nabokov localization file #{localization_file_name} update…")
      end

      checkout_master_branch

      ui.puts "Fetching remote master branch changes…".green
      self.git_repo.pull

      ui.puts "Merging the temporary branch into master…".green
      self.git_repo.merge_branches(self.nabokovfile.localizations_repo_master_branch, temporary_branch)

      ui.puts "Deleting temporary branch…".green
      self.git_repo.delete_branch(temporary_branch)

      ui.puts "Pushing changes to remote…".green
      self.git_repo.push
    end
  end
end
