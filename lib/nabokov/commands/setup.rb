require 'nabokov/version'
require 'claide'
require 'cork'
require 'fileutils'

module Nabokov
  class Setup < CLAide::Command
    self.summary = 'Set up the repository hook to sync app localization.'
    self.command = 'setup'
    self.version = Nabokov::VERSION

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
      FileUtils.chmod("u=x", @pre_commit_file)
    end

    def ensure_pre_commit_file_is_executable
      raise "pre commit file at '#{@pre_commit_file}' is not executable by the effective user id of this process" unless File.executable?(@pre_commit_file)
    end

    def default_git_path
      ".git"
    end

    def default_pre_commit_file
      "#{default_git_path}/hooks/pre-commit"
    end

  end
end
