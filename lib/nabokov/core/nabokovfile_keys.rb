module Nabokov
  class NabokovfileKeyes
    # @return [String] The key to get the localizations repo hash
    def self.localizations_repo
      return "git_repo"
    end

    # @return [String] The key to get the localizations remote URL string
    def self.localizations_repo_url
      return "url"
    end

    # @return [Hash] The key to get the master branch of the localizations repo
    def self.localizations_repo_master_branch
      return "master_branch"
    end

    # @return [Hash] The key to get the (localization_code => localization_file_path) hash
    def self.localization_file_paths
      return "localizations"
    end
  end
end
