require "nabokov/version"
require "nabokov/helpers/informator"
require "claide"
require "cork"

module Nabokov
  class Runner < CLAide::Command
    self.abstract_command = true
    self.summary = "Nabokov, the simple tool to keep your mobile app localization up to date."
    self.version = Nabokov::VERSION
    self.command = "nabokov"

    def initialize(argv)
      super
      @cork = Cork::Board.new(silent: argv.option("silent", false), verbose: argv.option("verbose", false))
    end

    def ui
      @ui ||= Informator.new(@cork)
    end
  end
end
