require 'nabokov/core/nabokovfile'

module Nabokov
  class Runner < CLAide::Command

    self.summary = 'Run the localization syncing.'
    self.command = 'nabokov'
    self.version = Nabokov::VERSION

    def initialize(argv)
      nabokovfile = argv.option('nabokovfile')
      @nabokovfile_path = nabokovfile if File.exist?(nabokovfile)
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
      git_repo = GitRepo.new(nabokovfile.localizations_repo_url)
      git_repo.clone
    end

  end
end
