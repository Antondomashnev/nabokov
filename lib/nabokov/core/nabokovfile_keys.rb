module Nabokov
  class NabokovfileKeyes

    # @return [String] The key to get the localizations remote URL string
    def self.localizations_repo_url
      return "git_repo"
    end

    # @return [Hash] The key to get the (localization_code => localization_file_path) hash
    def self.localization_file_paths
      return "localizations"
    end
  end
end
