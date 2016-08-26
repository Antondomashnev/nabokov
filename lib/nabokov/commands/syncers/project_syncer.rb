require 'nabokov/commands/syncers/syncer'
require 'nabokov/core/file_manager'
require 'nabokov/helpers/merger'

module Nabokov
  class ProjectSyncer < Syncer

    self.abstract_command = false
    self.summary = 'Sync local localization strings with the remote localizations repo.'

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
      fetch_localization_repo_master_branch_changes
      init_project_git_repo
    end

    private

    def init_project_git_repo
      @project_git_repo = GitRepo.new(@nabokovfile.project_local_path)
      raise "Could not find the project repo at '#{Dir.exists?(@project_git_repo.local_path)}'" unless Dir.exists?(@project_git_repo.local_path)
      ui.inform("Found existed project repo at #{@project_git_repo.local_path}...")
      @project_git_repo.init
    end

    def checkout_project_repo_temporary_branch
      ui.say("Checkout master branch…")
      self.git_repo.checkout_branch(self.nabokovfile.localizations_repo_master_branch)
      @rescue_commit_sha = self.git_repo.log(1)
    end

    def fetch_localization_repo_master_branch_changes
      ui.say("Fetching localization repo remote master branch changes...")
      self.git_repo.pull
    end
  end
end
