require 'nabokov/core/nabokovfile'
require 'nabokov/core/file_manager'
require 'nabokov/git/git_repo'
require 'nabokov/version'
require 'claide'
require 'cork'

module Nabokov
  class Runner < CLAide::Command

    self.summary = 'Run the localization syncing.'
    self.command = 'nabokov'
    self.version = Nabokov::VERSION

    def initialize(argv)
      nabokovfile = argv.option('nabokovfile')
      raise "nabokovfile is a required parameter and could not be nil" if nabokovfile.nil?

      @nabokovfile_path = nabokovfile if File.exist?(nabokovfile)
      @cork = Cork::Board.new(silent: argv.option('silent', false),
                              verbose: argv.option('verbose', false))
      super
    end

    def validate!
      super
      if self.class == Runner && !@nabokovfile_path
        help! "Could not find a Nabokovfile."
      end
    end

    def self.options
      [
        ['--nabokovfile=<path/to/nabokovfile>', 'The location of your Nabokovfile']
      ].concat(super)
    end

    def run
      nabokovfile = Nabokovfile.new(@nabokovfile_path)
      ui.puts "Hooray, your Nabokovfile is valid".green

      git_repo = GitRepo.new(nabokovfile.localizations_repo_url)
      ui.puts "Cloning the localization repo from #{nabokovfile.localizations_repo_url} into #{git_repo.local_path}"
      git_repo.clone

      ui.puts "Cleanup all temporary files, we don't wanna waste space on your hard drive=)"
      FileManager.remove(git_repo.local_path)
    end

    private

    def ui
      @cork
    end

  end
end
