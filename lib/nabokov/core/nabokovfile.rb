require "yaml"
require "uri"
require "nabokov/core/nabokovfile_keys"
require "nabokov/core/nabokovfile_content_validator"

module Nabokov
  class Nabokovfile
    attr_accessor :localizations_repo_url
    attr_accessor :localizations_repo_master_branch
    attr_accessor :localizations_repo_local_path

    attr_accessor :project_localization_file_paths
    attr_accessor :project_local_path

    def initialize(path)
      raise "Path is a required parameter" if path.nil?
      raise "Couldn't find nabokov file at '#{path}'" unless File.exist?(path)
      nabokovfile = File.read(path)
      yaml_data = read_data_from_yaml_file(nabokovfile, path)
      validate_content(yaml_data)
      read_content(yaml_data)
    end

    def name
      "Nabokovfile"
    end

    def localizations_repo_local_path
      return @localizations_repo_local_path unless @localizations_repo_local_path.nil?
      @localizations_repo_local_path ||= ""
    end

    private

    def read_data_from_yaml_file(yaml_file, path)
      YAML.load(yaml_file)
    rescue Psych::SyntaxError
      raise "File at '#{path}' doesn't have a legit YAML syntax"
    end

    def validate_content(content_hash)
      validator = NabokovfileContentValidator.new(content_hash)
      validator.validate
    end

    def read_content(content_hash)
      localizations_repo = content_hash[NabokovfileKeyes.localizations_repo]
      self.localizations_repo_url = localizations_repo[NabokovfileKeyes.localizations_repo_url]
      self.localizations_repo_master_branch = localizations_repo[NabokovfileKeyes.localizations_repo_master_branch].nil? ? "master" : localizations_repo[NabokovfileKeyes.localizations_repo_master_branch]
      project_repo = content_hash[NabokovfileKeyes.project_repo]
      self.project_localization_file_paths = project_repo[NabokovfileKeyes.project_localization_file_paths]
      self.project_local_path = project_repo[NabokovfileKeyes.project_local_path]
      self.localizations_repo_local_path = build_localization_local_path
    end

    def build_localization_local_path
      repo_url_path = URI(self.localizations_repo_url).path.to_s
      home_dir = Dir.home.to_s
      repo_url_name_without_extension = File.basename(repo_url_path, File.extname(repo_url_path)).downcase
      repo_url_organization = File.dirname(repo_url_path).downcase
      nabokov_dir_name = "/.nabokov"
      home_dir + nabokov_dir_name + repo_url_organization + "/" + repo_url_name_without_extension
    end
  end
end
