require 'nabokov/core/nabokovfile'

describe Nabokov::Nabokovfile do
  it "raises an exception if there is no nabokovfile at the given path" do
    expect { Nabokov::Nabokovfile.new('./nabokovfile.yml') }.to raise_error("Couldn't find nabokov file at './nabokovfile.yml'")
  end

  it "raises an exception if the file does not have a legit YAML syntax" do
    expect { Nabokov::Nabokovfile.new('spec/fixtures/nabokovfile_example_invalid.yaml') }.to raise_error("File at 'spec/fixtures/nabokovfile_example_invalid.yaml' doesn't have a legit YAML syntax")
  end

  it "assigns the localization_git_repo value from valid nabokovfile" do
    nabokovfile = Nabokov::Nabokovfile.new('spec/fixtures/nabokovfile_example.yaml')
    expect(nabokovfile.localizations_repo_url).to eql("https://github.com/Antondomashnev/nabokov_example.git")
  end

  it "assigns the localization_file_paths value from valid nabokovfile" do
    nabokovfile = Nabokov::Nabokovfile.new('spec/fixtures/nabokovfile_example.yaml')
    expect(nabokovfile.localization_file_paths) == {"en" => "spec/fixtures/en.stirngs", "de" => "spec/fixtures/de.strings"}
  end
end
