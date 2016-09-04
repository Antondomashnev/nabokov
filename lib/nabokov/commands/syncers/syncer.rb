require "nabokov/commands/runner"
require "nabokov/core/nabokovfile"
require "nabokov/core/file_manager"
require "nabokov/git/git_repo"

module Nabokov
  class Syncer < Runner
    attr_reader :nabokovfile
    attr_reader :git_repo

    self.abstract_command = true
    self.summary = "The abstract super class for all nabokov sync related commands."

    def initialize(argv)
      nabokovfile = argv.option("nabokovfile")
      unless nabokovfile
        pwd_nabokovfile = Pathname.pwd + "Nabokovfile.yaml"
        nabokovfile = pwd_nabokovfile if File.exist?(pwd_nabokovf)
      end
      raise "--nabokovfile is a required parameter and could not be nil" if nabokovfile.nil?

      @nabokovfile_path = nabokovfile if File.exist?(nabokovfile)
      super
    end

    def validate!
      super
      if self.class == Syncer && !@nabokovfile_path
        help! "Could not find a Nabokovfile."
      end
    end

    def self.options
      [
        ["--nabokovfile=<path/to/nabokovfile>", "The location of your Nabokovfile"]
      ].concat(super)
    end

    def run
      initialize_nabokov_file
      init_git_repo
      self
    end

    def initialize_nabokov_file
      @nabokovfile = Nabokovfile.new(@nabokovfile_path)
      ui.inform("Hooray, your Nabokovfile is valid...")
    end

    def init_git_repo
      @git_repo = GitRepo.new(@nabokovfile.localizations_repo_local_path, @nabokovfile.localizations_repo_url)
      if Dir.exist?(@git_repo.local_path)
        ui.inform("Found existed repo at #{@git_repo.local_path}...")
        @git_repo.init
      else
        ui.inform("Cloning the localization repo from #{@git_repo.remote_url} into #{@git_repo.local_path}...")
        @git_repo.clone
      end
      checkout_master_branch
    end

    def checkout_master_branch
      ui.inform("Checkout master branch...")
      @git_repo.checkout_branch(@nabokovfile.localizations_repo_master_branch)
    end
  end
end
