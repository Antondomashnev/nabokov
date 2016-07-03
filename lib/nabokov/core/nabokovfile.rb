require 'YAML'
require 'uri'
require 'nabokov/core/nabokovfile_keys'
require 'nabokov/core/nabokovfile_content_validator'

module Nabokov
  class Nabokovfile

    # @return [URL] repote localizations repository URL
    attr_accessor :localizations_repo_url
    # @return hash with key as a localization code (e.x en_US)
    #         and value as a path to localization strings file
    attr_accessor :localization_file_paths

    def initialize(path)
      raise "Couldn't find nabokov file at '#{path}'" unless File.exist?(path)
      nabokovfile = File.read(path)
      yaml_data = read_data_from_yaml_file(nabokovfile, path)
      validate_content(yaml_data)
      read_content(yaml_data)
    end

    private

    def read_data_from_yaml_file(yaml_file, path)
      begin
        yaml_data = YAML.load(yaml_file)
      rescue Exception => e
        raise "File at '#{path}' doesn't have a legit YAML syntax"
      end
    end

    def validate_content(content_hash)
      validator = NabokovfileContentValidator.new(content_hash)
      validator.validate
    end

    def read_content(content_hash)
      self.localizations_repo_url = content_hash[NabokovfileKeyes.localizations_repo_url]
      self.localization_file_paths = content_hash[NabokovfileKeyes.localization_file_paths]
    end
  end
end
