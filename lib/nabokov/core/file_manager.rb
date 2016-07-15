require 'fileutils'
require 'pathname'

module Nabokov
  class FileManager

    def self.copy_and_rename(original_file_path, to_directory, new_name)
      raise "Couldn't find file at '#{original_file_path}'" unless File.exist?(original_file_path)
      raise "Couldn't find directory at '#{to_directory}'" unless Dir.exist?(to_directory)
      raise "New name of the file could not be empty" unless new_name.length > 0
      raise "New name of the file '#{new_name}' contains invalid character '.'" if new_name.include?(".")

      original_file_pathname = Pathname.new(original_file_path)
      original_file_extension = original_file_pathname.extname
      new_file_pathname = Pathname.new(to_directory) + Pathname.new(new_name + original_file_extension)
      new_file_path = new_file_pathname.to_s
      FileUtils.cp(original_file_path, new_file_path)
      new_file_path
    end

    def self.remove(path)
      raise "Can not file neither file nor directory at '#{path}'" unless (File.exist?(path) or Dir.exist?(path))
    end

  end
end
