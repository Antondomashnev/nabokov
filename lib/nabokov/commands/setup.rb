require "nabokov/commands/runner"
require "fileutils"
require "nabokov/core/nabokovfile"
require "nabokov/core/file_manager"
require "nabokov/git/git_repo"

module Nabokov
  # Command to setup the project repo to use nabokov
  # It setups the pre commit hook to start Nabokov::LocalizationsRepoSyncer
  class Setup < Runner
    self.summary = "Setups the repository hook to sync app localizations."
    self.command = "setup"
    self.description = "Installs the pre-commit git hook with the logic to run 'nabokov sync localizations'"

    attr_reader :pre_commit_file

    def initialize(argv)
      @pre_commit_file = argv.option("pre_commit_file")
      @pre_commit_file ||= default_pre_commit_file
      @git_path = argv.option("git_path")
      @git_path ||= default_git_path
      super
    end

    def run
      ensure_pre_commit_file_exists
      ensure_pre_commit_file_is_executable
      ensure_hook_is_installed
      ui.important "nabokov pre commit git hook is installed"
      self
    end

    private

    def ensure_pre_commit_file_exists
      @pre_commit_file = File.realpath(@pre_commit_file) if File.symlink?(@pre_commit_file)
      return if File.exist?(@pre_commit_file)

      raise ".git folder is not found at '#{@git_path}'" unless Dir.exist?(@git_path)

      FileUtils.mkdir_p("#{@git_path}/hooks")
      @pre_commit_file = "#{@git_path}/hooks/pre-commit"
      FileUtils.touch(@pre_commit_file)
      FileUtils.chmod("u=xwr", @pre_commit_file)
    end

    def ensure_pre_commit_file_is_executable
      raise "pre commit file at '#{@pre_commit_file}' is not executable by the effective user id of this process" unless File.executable?(@pre_commit_file)
    end

    def ensure_hook_is_installed
      git_repo_path = ""
      IO.popen("git rev-parse --show-toplevel", "r+") do |pipe|
        git_repo_path = pipe.read
      end
      return if File.foreach(@pre_commit_file).grep(/git_repo_path/).any?

      File.open(@pre_commit_file, "r+") do |f|
        f.puts("#!/usr/bin/env bash")
        f.puts("current_repo_path=\$(git rev-parse --show-toplevel)")
        f.puts("nabokovfile_path=\"$current_repo_path/Nabokovfile\"")
        f.puts("tracking_repo_path=\"#{git_repo_path}\"")
        f.puts("if [ \"$current_repo_path\" == \"$tracking_repo_path\" ] && gem list -i nabokov && [ -e \"$nabokovfile_path\" ]; then nabokov sync localizations --nabokovfile=$nabokovfile_path || exit 1; fi")
      end
    end

    def default_git_path
      ".git"
    end

    def default_pre_commit_file
      "#{default_git_path}/hooks/pre-commit"
    end
  end
end
