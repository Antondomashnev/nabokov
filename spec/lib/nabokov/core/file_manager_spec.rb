require 'nabokov/core/file_manager'

describe Nabokov::FileManager do

  describe "copy and rename" do
    after(:example) do
      FileUtils.rm_rf(Dir.glob("spec/fixtures/test_copy_folder/*"))
    end

    context "when there is no file at from_path" do
      it "raises an exception" do
        from_path = "spec/fixtures/fr.strings"
        to_directory = "spec/fixtures/test_copy_folder/"
        new_file_name = "fr.strings"
        expect { Nabokov::FileManager.copy_and_rename(from_path, to_directory, new_file_name) }.to raise_error("Couldn't find file at 'spec/fixtures/fr.strings'")
      end
    end

    context "when there is no directory to copy to" do
      it "raises an exception" do
        from_path = "spec/fixtures/de.strings"
        to_directory = "spec/fixtures/test_copy_folder_fake"
        new_file_name = "fr.strings"
        expect { Nabokov::FileManager.copy_and_rename(from_path, to_directory, new_file_name) }.to raise_error("Couldn't find directory at 'spec/fixtures/test_copy_folder_fake'")
      end
    end

    context "when the new file name is empty" do
      it "raises an exception" do
        from_path = "spec/fixtures/de.strings"
        to_directory = "spec/fixtures/test_copy_folder"
        new_file_name = ""
        expect { Nabokov::FileManager.copy_and_rename(from_path, to_directory, new_file_name) }.to raise_error("New name of the file could not be empty")
      end
    end

    context "when the new file name contains the '.'" do
      it "raises an exception because it messes up with the extension delimeter" do
        from_path = "spec/fixtures/de.strings"
        to_directory = "spec/fixtures/test_copy_folder"
        new_file_name = "fr.de"
        expect { Nabokov::FileManager.copy_and_rename(from_path, to_directory, new_file_name) }.to raise_error("New name of the file 'fr.de' contains invalid character '.'")
      end
    end

    context "when all requirenments are fulfilled" do
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

  describe "remove" do
    context "when the given path is neither directory nor file" do
      it "raises an error" do
        expect { Nabokov::FileManager.remove("spec/fixtures/not_existed_file.rb") }.to raise_error("Can not file neither file nor directory at 'spec/fixtures/not_existed_file.rb'")
      end
    end

    context "when the given path is file" do
      before do
        FileUtils.mkdir_p('spec/fixtures/test_copy_folder/file.rb')
      end

      it "removes the file at the given path" do
        Nabokov::FileManager.remove("spec/fixtures/test_copy_folder/file.rb")
        expect(File.exist?("spec/fixtures/test_copy_folder/file.rb")).to be_falsy
      end
    end

    context "when the given path is directory" do
      before do
        FileUtils.mkdir_p('spec/fixtures/test_copy_folder/folder')
      end

      it "removes the directory at the given path" do
        Nabokov::FileManager.remove("spec/fixtures/test_copy_folder/folder")
        expect(Dir.exist?("spec/fixtures/test_copy_folder/folder")).to be_falsy
      end
    end
  end

  describe "copy" do
    context "when file to copy doesn't exist at the given path" do
      it "raises an error" do
        expect { Nabokov::FileManager.copy("dsaklgadsg/fadsgf/rewr.rb", "spec/fixtures/test_copy_folder/file.rb") }.to raise_error("Couldn't find file at 'dsaklgadsg/fadsgf/rewr.rb'")
      end
    end

    context "when file exists at the given path" do
      after do
        FileUtils.rm_rf(Dir.glob("spec/fixtures/test_copy_folder/*"))
      end

      it "copies file to the given path" do
        Nabokov::FileManager.copy("spec/fixtures/de.strings", "spec/fixtures/test_copy_folder/file.rb")
        expect(File.exist?("spec/fixtures/test_copy_folder/file.rb"))
      end
    end
  end
end
