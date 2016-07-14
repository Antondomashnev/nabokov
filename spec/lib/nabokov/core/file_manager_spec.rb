require 'nabokov/core/file_manager'

describe Nabokov::FileManager do

  context "copy and rename" do

    after(:example) do
      FileUtils.rm_rf Dir.glob("spec/fixtures/test_copy_folder/*")
    end

    it "raises an exception if there is no file at from_path" do
      from_path = "spec/fixtures/fr.strings"
      to_directory = "spec/fixtures/test_copy_folder/"
      new_file_name = "fr.strings"
      expect { Nabokov::FileManager.copy_and_rename(from_path, to_directory, new_file_name) }.to raise_error("Couldn't find file at 'spec/fixtures/fr.strings'")
    end

    it "raises an exception if there is no directory to copy to" do
      from_path = "spec/fixtures/de.strings"
      to_directory = "spec/fixtures/test_copy_folder_fake"
      new_file_name = "fr.strings"
      expect { Nabokov::FileManager.copy_and_rename(from_path, to_directory, new_file_name) }.to raise_error("Couldn't find directory at 'spec/fixtures/test_copy_folder_fake'")
    end

    it "raises an exception if the new file name is empty" do
      from_path = "spec/fixtures/de.strings"
      to_directory = "spec/fixtures/test_copy_folder"
      new_file_name = ""
      expect { Nabokov::FileManager.copy_and_rename(from_path, to_directory, new_file_name) }.to raise_error("New name of the file could not be empty")
    end

    it "raises an exception if the new file name contains the '.' because it messes up with the extension delimeter" do
      from_path = "spec/fixtures/de.strings"
      to_directory = "spec/fixtures/test_copy_folder"
      new_file_name = "fr.de"
      expect { Nabokov::FileManager.copy_and_rename(from_path, to_directory, new_file_name) }.to raise_error("New name of the file 'fr.de' contains invalid character '.'")
    end

    it "copies the file according input parameters" do
      from_path = "spec/fixtures/de.strings"
      to_directory = "spec/fixtures/test_copy_folder"
      new_file_name = "fr"
      new_file_path = Nabokov::FileManager.copy_and_rename(from_path, to_directory, new_file_name)
      expect(File.file?(new_file_path)).to be_truthy
    end

    it "overwrites the file according input parameters" do
      from_path = "spec/fixtures/de.strings"
      to_directory = "spec/fixtures/test_overwrite_folder"
      new_file_name = "fr"
      time_before_copy = File.mtime("spec/fixtures/test_overwrite_folder/fr.strings")
      new_file_path = Nabokov::FileManager.copy_and_rename(from_path, to_directory, new_file_name)
      expect(File.mtime(new_file_path)).to be > time_before_copy
    end

  end

end
