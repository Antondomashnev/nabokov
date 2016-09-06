require "nabokov/core/nabokovfile"

describe Nabokov::Nabokovfile do
  context "when there is no nabokovfile at the given path" do
    it "raises an exception" do
      expect { Nabokov::Nabokovfile.new("./nabokovfile.yml") }.to raise_error("Couldn't find nabokov file at './nabokovfile.yml'")
    end
  end

  context "when the file does not have a legit YAML syntax" do
    it "raises an exception" do
      expect { Nabokov::Nabokovfile.new("spec/fixtures/nabokovfile_example_invalid.yaml") }.to raise_error("File at 'spec/fixtures/nabokovfile_example_invalid.yaml' doesn't have a legit YAML syntax")
    end
  end

  context "when the file has legit YAML syntax and exists" do
    before do
      @nabokovfile = Nabokov::Nabokovfile.new("spec/fixtures/nabokovfile_example.yaml")
    end

    it "assigns the localization_git_repo value" do
      expect(@nabokovfile.localizations_repo_url).to eql("https://github.com/Antondomashnev/nabokov_example.git")
    end

    it "assigns the project_localization_file_paths value" do
      expect(@nabokovfile.project_localization_file_paths) == { "en" => "spec/fixtures/en.stirngs", "de" => "spec/fixtures/de.strings" }
    end

    it "assigns the localization_local_path value" do
      expect(@nabokovfile.localizations_repo_local_path).to eql("#{Dir.home}/.nabokov/antondomashnev/nabokov_example")
    end

    it "assigns the project_local_path value" do
      expect(@nabokovfile.project_local_path).to eql("spec/fixtures/local_project")
    end

    context "when the master_branch key is presented" do
      it "assigns the localizations_repo_master_branch value" do
        expect(@nabokovfile.localizations_repo_master_branch).to eql("shmaster")
      end
    end

    context "when the master_branch key is not presented" do
      before do
        @nabokovfile = Nabokov::Nabokovfile.new("spec/fixtures/nabokovfile_example_without_master_branch.yaml")
      end

      it "assigns the localizations_repo_master_branch default value" do
        expect(@nabokovfile.localizations_repo_master_branch).to eql("master")
      end
    end
  end
end
