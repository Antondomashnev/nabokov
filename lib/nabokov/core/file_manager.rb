require 'fileutils'

module Nabokov
  class FileManager

    def self.copy_and_rename(from_path, to_directory, new_name)
      raise "Couldn't find file at '#{from_path}'" unless File.exist?(from_path)
      raise "Couldn't find directory at '#{to_directory}'" unless Dir.exist?(to_directory)
      raise "New name of the file could not be empty" unless new_name.length > 0
    end

  end
end
