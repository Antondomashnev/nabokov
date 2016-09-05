require "nabokov/version"
require "nabokov/helpers/informator"
require "claide"
require "cork"

module Nabokov
  class Runner < CLAide::Command
    self.abstract_command = true
    self.summary = "The abstract super class for all nabokov commands."
    self.version = Nabokov::VERSION
    self.command = "nabokov"

    def initialize(argv)
      super
      @cork = Cork::Board.new(silent: argv.option("silent", false), verbose: argv.option("verbose", false))
    end

    def ui
      if self.verbose
        @ui ||= Informator.new(@cork, self.verbose)
      else
        @ui ||= Informator.new(@cork)
      end
    end
  end
end
