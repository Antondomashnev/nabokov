require 'nabokov/commands/runner'

module Nabokov
  class Syncer < Runner

    attr_reader :nabokovfile
    attr_reader :git_repo

    self.abstract_command = true
    self.summary = 'The abstract super class for all nabokov sync related commands.'

    def initialize(argv)
      nabokovfile = argv.option('nabokovfile')
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
        ['--nabokovfile=<path/to/nabokovfile>', 'The location of your Nabokovfile']
      ].concat(super)
    end

    def run
      initialize_nabokov_file
      prepare_git_repo
      self
    end

    private

    def initialize_nabokov_file
      @nabokovfile = Nabokovfile.new(@nabokovfile_path)
      ui.puts "Hooray, your Nabokovfile is valid".green
    end

    def prepare_git_repo
      @git_repo = GitRepo.new(@nabokovfile.localizations_repo_url, @nabokovfile.localizations_local_path)
      if Dir.exists?(@git_repo.local_path)
        ui.puts "Found existed repo at #{@git_repo.local_path}".green
        ui.puts "Syncing the localization repo at #{@git_repo.local_path} with upstream".green
        @git_repo.init
        @git_repo.checkout_branch(@nabokovfile.localizations_repo_master_branch)
        @git_repo.pull
      else
        ui.puts "Cloning the localization repo from #{@git_repo.remote_url} into #{@git_repo.local_path}".green
        @git_repo.clone
      end
    end

  end
end
