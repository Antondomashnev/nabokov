require 'nabokov/core/nabokovfile'
require 'nabokov/core/file_manager'
require 'nabokov/git/git_repo'
require 'nabokov/version'
require 'nabokov/helpers/cork_helper'
require 'claide'
require 'cork'

module Nabokov
  class Runner < CLAide::Command

    self.abstract_command = true
    self.summary = 'The abstract super class for all nabokov commands.'
    self.version = Nabokov::VERSION

    def initialize(argv)
      @cork = Cork::Board.new(silent: argv.option('silent', false), verbose: argv.option('verbose', false))
      super
    end

    def ui
      @ui ||= CorkHelper.new(@cork)
    end

  end
end
