require "uri"
require "nabokov/core/nabokovfile_keys"

module Nabokov
  # This class is responsible for nabokovfile content validation
  # The validation rules are for localizations_repo and project_repo settings
  class NabokovfileContentValidator
    attr_accessor :nabokovfile_hash

    def initialize(nabokovfile_hash)
      self.nabokovfile_hash = nabokovfile_hash
    end

    # Performs validation
    # First rule: localizations_repo should be the type of Hash
    #             localizations_repo_url should be valid URL with secure https scheme
    # Second rule: project_repo should be the type of Hash
    #              project localizations_key should be the of Hash
    #              project_localization_file_paths should point to existed files
    #              project_local_path should point to valid folder
    def validate
      validate_localizations_repo
      validate_project_repo
    end

    private

    def validate_localizations_repo
      localizations_repo = self.nabokovfile_hash[NabokovfileKeyes.localizations_repo]
      raise "Localizations repo must be a type of Hash" unless localizations_repo.kind_of?(Hash)

      url = localizations_repo[NabokovfileKeyes.localizations_repo_url]
      raise "'#{url}' is not a valid URL" unless url =~ URI.regexp
      raise "Please use 'https://...' instead of '#{url}' only supports encrypted requests" unless url.start_with?("https://")
    end

    def validate_project_repo
      project_repo = self.nabokovfile_hash[NabokovfileKeyes.project_repo]
      raise "Project repo must be a type of Hash" unless project_repo.kind_of?(Hash)

      localizations_key = NabokovfileKeyes.project_localization_file_paths
      localizations = project_repo[localizations_key]
      raise "Localizations must be a type of Hash" unless localizations.kind_of?(Hash)
      localizations.each_value { |path| raise "Couldn't find strings file at '#{path}'" unless File.exist?(path) }

      project_local_path_key = NabokovfileKeyes.project_local_path
      project_local_path = project_repo[project_local_path_key]
      raise "Project repo local path must be presented" if project_local_path.nil?
    end
  end
end
