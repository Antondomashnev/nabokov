require 'nabokov/core/nabokovfile_keys'

describe Nabokov::NabokovfileKeyes do
  it "has a valid git_repo key" do
    expect(Nabokov::NabokovfileKeyes.localizations_repo_url).to eql("git_repo")
  end

  it "has a valid localizations hash key" do
    expect(Nabokov::NabokovfileKeyes.localization_file_paths).to eql("localizations")
  end
end
