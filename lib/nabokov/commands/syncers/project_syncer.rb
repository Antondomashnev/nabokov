require "nabokov/commands/syncers/syncer"
require "nabokov/core/file_manager"
require "nabokov/helpers/merger"
require "nabokov/models/strings_file"

module Nabokov
  class ProjectSyncer < Syncer
    self.abstract_command = false
    self.command = "project"
    self.summary = "Synchronize project localization strings with the remote localizations repo."

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
      ui.important("Nabokov starts project repo synchronization")
      super
      fetch_localization_repo_master_branch_changes
      init_project_git_repo
      checkout_project_repo_temporary_branch
      has_changes = update_localization_files_in_project_repo
      checkout_project_repo_original_branch
      if has_changes
        merge_project_repo_original_branch_with_temporary
      end
      delete_temporary_branch
      notify_user_about_finish
    end

    private

    def notify_user_about_finish
      if @synchronized_file_names.count > 0
        ui.say("#{@synchronized_file_names} have been updated in project.")
        ui.say("Your are all set.")
      else
        ui.say("Nothing to synchronize, localizations in the remote")
        ui.say("repo and project repo are the same.")
      end
      ui.important("Nabokov has finished project repo synchronization 🎉")
    end

    def init_project_git_repo
      @project_git_repo = GitRepo.new(@nabokovfile.project_local_path)
      raise "Could not find the project repo at '#{Dir.exist?(@project_git_repo.local_path)}'" unless Dir.exist?(@project_git_repo.local_path)
      ui.say("Found existed project repo at #{@project_git_repo.local_path}...") if self.verbose
      @project_git_repo.init
      @project_repo_original_branch = @project_git_repo.current_branch
    end

    def merge_project_repo_original_branch_with_temporary
      merger = Merger.new(ui, @project_git_repo)
      merger.merge(@project_repo_original_branch, temporary_branch)
    end

    def checkout_project_repo_temporary_branch
      ui.say("Checkout porject repo temporary branch...") if self.verbose
      @project_git_repo.checkout_branch(temporary_branch)
    end

    def checkout_project_repo_original_branch
      ui.say("Checkout project repo #{@project_repo_original_branch} branch...")
      @project_git_repo.checkout_branch(@project_repo_original_branch)
    end

    def update_localization_files_in_project_repo
      has_changes = false
      self.nabokovfile.project_localization_file_paths.each do |localization_file_name, localization_file_path|
        localization_file_path_in_localization_repo = "#{self.git_repo.local_path}/#{localization_file_name}.#{Nabokov::StringsFile.extension}"
        ui.say("Copying strings file from '#{localization_file_path_in_localization_repo}' to the project repo...") if self.verbose
        new_file_path = FileManager.copy(localization_file_path_in_localization_repo, localization_file_path)
        @project_git_repo.add(new_file_path)
        if @project_git_repo.changes?
          @synchronized_file_names << localization_file_name
          @project_git_repo.commit("Nabokov has updated localization file '#{localization_file_name}'...")
          has_changes = true
        else
          ui.say("'#{localization_file_name}' file doesn't have any changes to commit...") if self.verbose
        end
      end
      has_changes
    end

    def fetch_localization_repo_master_branch_changes
      ui.say("Fetching localization repo remote master branch changes...") if self.verbose
      self.git_repo.pull
    end

    def delete_temporary_branch
      ui.say("Deleting temporary branch...") if self.verbose
      @project_git_repo.delete_branch(temporary_branch)
    end

    def temporary_branch
      "nabokov/temporary_branch"
    end
  end
end
