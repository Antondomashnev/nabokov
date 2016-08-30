require 'uri'
require 'nabokov/core/nabokovfile_keys'

module Nabokov
  class NabokovfileContentValidator

    attr_accessor :nabokovfile_hash

    def initialize(nabokovfile_hash)
      self.nabokovfile_hash = nabokovfile_hash
    end

    def validate
      validate_localizations_repo
      validate_project_repo
    end

    private

    def validate_localizations_repo
      localizations_repo = self.nabokovfile_hash[NabokovfileKeyes.localizations_repo]
      raise "Localizations repo must be a type of Hash" unless localizations_repo.is_a?(Hash)

      url = localizations_repo[NabokovfileKeyes.localizations_repo_url]
      raise "'#{url}' is not a valid URL" unless url =~ URI::regexp()
      raise "Please use 'https://...' instead of '#{url}' only supports encrypted requests" unless url.start_with?("https://")
    end

    def validate_project_repo
      project_repo = self.nabokovfile_hash[NabokovfileKeyes.project_repo]
      raise "Project repo must be a type of Hash" unless project_repo.is_a?(Hash)

      localizations_key = NabokovfileKeyes.project_localization_file_paths
      localizations = project_repo[localizations_key]
      raise "Localizations must be a type of Hash" unless localizations.is_a?(Hash)
      localizations.each_value { |path| raise "Couldn't find strings file at '#{path}'" unless File.exist?(path) }

      project_local_path_key = NabokovfileKeyes.project_local_path
      project_local_path = project_repo[project_local_path_key]
      raise "Project repo local path must be presented" if project_local_path.nil?
    end

  end
end
