require 'nabokov/commands/syncers/syncer'
require 'nabokov/core/file_manager'
require 'nabokov/helpers/merger'

module Nabokov
  class ProjectSyncer < Syncer

    self.abstract_command = false
    self.summary = 'Sync local localization strings with the remote localizations repo.'

    def initialize(argv)
      super
    end

    def validate!
      super
    end

    def self.options
      super
    end

    def run
      super
    end

    private

  end
end
