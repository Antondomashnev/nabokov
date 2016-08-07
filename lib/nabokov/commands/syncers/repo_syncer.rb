require 'nabokov/commands/syncers/syncer'
require 'nabokov/core/file_manager'

module Nabokov
  class RepoSyncer < Syncer

    self.abstract_command = false
    self.summary = 'Sync remote localizations repo with the local localization strings.'

    def initialize(argv)
      super
      @has_changes = false
    end

    def validate!
      super
    end

    def self.options
      super
    end

    def run
      super
      checkout_temporary_branch
      update_localization_files
      if @has_changes
        checkout_master_branch
        fetch_master_branch_changes
        merge_master_branch_with_temporary
        delete_temporary_branch
        push_changes_to_remote
      else
        checkout_master_branch
        fetch_master_branch_changes
        delete_temporary_branch
      end
    end

    private

    def checkout_temporary_branch
      ui.puts "Checkout a temporary branch for new localization strings…".green
      self.git_repo.checkout_branch(temporary_branch)
    end

    def update_localization_files
      self.nabokovfile.localization_file_paths.each do |localization_file_name, localization_file_path|
        ui.puts "Copying strings file from '#{localization_file_path}' to the repo…".green
        new_file_path = FileManager.copy_and_rename(localization_file_path, self.git_repo.local_path, localization_file_name.to_s)
        self.git_repo.add(new_file_path)
        if self.git_repo.has_changes
          self.git_repo.commit("Nabokov localization file '#{localization_file_name}' update…")
          @has_changes = true
        else
          ui.puts "'#{localization_file_name}' file doesn't have any changes to commit…".green
        end
      end
    end

    def checkout_master_branch
      ui.puts "Checkout master branch…".green
      self.git_repo.checkout_branch(self.nabokovfile.localizations_repo_master_branch)
    end

    def fetch_master_branch_changes
      ui.puts "Fetching remote master branch changes…".green
      self.git_repo.pull
    end

    def delete_temporary_branch
      ui.puts "Deleting temporary branch…".green
      self.git_repo.delete_branch(temporary_branch)
    end

    def push_changes_to_remote
      ui.puts "Pushing changes to remote…".green
      self.git_repo.push
    end

    def merge_master_branch_with_temporary
      ui.puts "Merging temporary branch into master…".green
      self.git_repo.merge_branches(self.nabokovfile.localizations_repo_master_branch, temporary_branch)
    end

    def temporary_branch
      "nabokov/temporary_branch"
    end
  end
end
