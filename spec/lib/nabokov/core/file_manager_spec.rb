require 'nabokov/core/file_manager'

describe Nabokov::FileManager do

  context "copy and rename" do
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
  end

end
