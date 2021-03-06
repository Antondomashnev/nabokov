require "fileutils"
require "pathname"

module Nabokov
  # This class is the wrapper around the FileUtils
  class FileManager
    # Copies given file to the given destination
    def self.copy(original_file_path, destination_file_path)
      raise "Couldn't find file at '#{original_file_path}'" unless File.exist?(original_file_path)
      FileUtils.cp(original_file_path, destination_file_path)
      File.expand_path(destination_file_path)
    end

    # Copies given file to the given destination and renames to the given name
    # Note: the extension of the file remains the same that's why new name can not contain '.'
    def self.copy_and_rename(original_file_path, to_directory, new_name)
      raise "Couldn't find file at '#{original_file_path}'" unless File.exist?(original_file_path)
      raise "Couldn't find directory at '#{to_directory}'" unless Dir.exist?(to_directory)
      raise "New name of the file could not be empty" if new_name.empty?
      raise "New name of the file '#{new_name}' contains invalid character '.'" if new_name.include?(".")

      original_file_pathname = Pathname.new(original_file_path)
      original_file_extension = original_file_pathname.extname
      new_file_pathname = Pathname.new(to_directory) + Pathname.new(new_name + original_file_extension)
      new_file_path = new_file_pathname.to_s
      FileUtils.cp(original_file_path, new_file_path)
      File.expand_path(new_file_path)
    end

    # Removes the filve at the given path
    def self.remove(path)
      raise "Can not file neither file nor directory at '#{path}'" unless File.exist?(path) or Dir.exist?(path)
      FileUtils.rm_rf(path)
    end
  end
end
