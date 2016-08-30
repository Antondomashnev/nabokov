module Nabokov
  class NabokovfileKeyes
    # @return [String] The key to get the localization's repo hash
    def self.localizations_repo
      return "localizations_repo"
    end

    # @return [String] The key to get the localizations remote URL string
    def self.localizations_repo_url
      return "url"
    end

    # @return [Hash] The key to get the master branch of the localizations repo
    def self.localizations_repo_master_branch
      return "master_branch"
    end

    # @return [String] The key to get the project's repo hash
    def self.project_repo
      return "project_repo"
    end

    # @return [Hash] The key to get the (localization_code => localization_file_path) hash
    def self.project_localization_file_paths
      return "localizations"
    end

    # @return [Hash] The key to get the project's local path
    def self.project_local_path
      return "local_path"
    end
  end
end
