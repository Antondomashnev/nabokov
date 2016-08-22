require 'nabokov/commands/runner'
require 'fileutils'

module Nabokov
  class Setup < Runner
    self.summary = 'Set up the repository hook to sync app localization.'
    self.command = 'setup'

    attr_reader :pre_commit_file

    def initialize(argv)
      @pre_commit_file = argv.option('pre_commit_file')
      @pre_commit_file ||= default_pre_commit_file
      @git_path = argv.option('git_path')
      @git_path ||= default_git_path
      super
    end

    def run
      ensure_pre_commit_file_exists
      ensure_pre_commit_file_is_executable
      ensure_hook_is_installed
      self
    end

    private

    def ensure_pre_commit_file_exists
      @pre_commit_file = File.realpath(@pre_commit_file) if File.symlink?(@pre_commit_file)
      return if File.exists?(@pre_commit_file)

      raise ".git folder is not found at '#{@git_path}'" unless Dir.exist?(@git_path)

      FileUtils::mkdir_p("#{@git_path}/hooks")
      @pre_commit_file = "#{@git_path}/hooks/pre-commit"
      FileUtils.touch(@pre_commit_file)
      FileUtils.chmod("u=xwr", @pre_commit_file)
    end

    def ensure_pre_commit_file_is_executable
      raise "pre commit file at '#{@pre_commit_file}' is not executable by the effective user id of this process" unless File.executable?(@pre_commit_file)
    end

    def ensure_hook_is_installed
      git_repo_path = system('git rev-parse --show-toplevel')
      return if File.foreach(@pre_commit_file).grep(/git_repo_path/).any?

      File.open(@pre_commit_file, 'r+') { |f|
        f.puts("#!/usr/bin/env bash")
        f.puts("current_repo_path=\$(git rev-parse --show-toplevel)")
        f.puts("nabokovfile_path=\"$current_repo_path/Nabokovfile\"")
        f.puts("tracking_repo_path=\"#{git_repo_path}\"")
        f.puts("if [ \"$current_repo_path\" == \"$tracking_repo_path\" ] && gem list -i nabokov && [ -e \"$nabokovfile_path\" ]; then nabokov --nabokovfile=$nabokovfile_path || exit 1; fi")
      }
    end

    def default_git_path
      ".git"
    end

    def default_pre_commit_file
      "#{default_git_path}/hooks/pre-commit"
    end

  end
end
