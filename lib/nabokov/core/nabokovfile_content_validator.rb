require 'uri'
require 'nabokov/core/nabokovfile_keys'

module Nabokov
  class NabokovfileContentValidator

    attr_accessor :nabokovfile_hash

    def initialize(nabokovfile_hash)
      self.nabokovfile_hash = nabokovfile_hash
    end

    def validate
      validate_git_repo
      validate_localizations
    end

    private

    def validate_git_repo
      url_key = NabokovfileKeyes.localizations_repo_url
      url = self.nabokovfile_hash[url_key]
      raise "'#{url}' is not a valid URL" unless url =~ URI::regexp()
      raise "Please use 'https://...' instead of '#{url}' only supports encrypted requests" unless url.start_with?("https://")
    end

    def validate_localizations
      localizations_key = NabokovfileKeyes.localization_file_paths
      localizations = self.nabokovfile_hash[localizations_key]
      raise "Localizations must be a type of Hash" unless localizations.is_a?(Hash)

      localizations.each_value { |path| raise "Couldn't find strings file at '#{path}'" unless File.exist?(path) }
    end

  end
end
