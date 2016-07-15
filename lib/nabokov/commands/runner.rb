require 'nabokov/core/nabokovfile'

module Nabokov
  class Runner < CLAide::Command

    self.summary = 'Run the localization syncing.'
    self.command = 'nabokov'
    self.version = Nabokov::VERSION

    def initialize(argv)
      nabokovfile = argv.option('nabokovfile')
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
      ui.puts "Running nabokov...".green
      nabokovfile = Nabokovfile.new(@nabokovfile_path, @cork)
      ui.puts "Ye, your nabokovfile is valid".green
      git_repo = GitRepo.new(nabokovfile.localizations_repo_url)
      ui.puts "Cloning the localization repo from #{nabokovfile.localizations_repo_url}"
      git_repo.clone
    end

  end
end
