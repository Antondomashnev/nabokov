require 'nabokov/core/nabokovfile_keys'

describe Nabokov::NabokovfileKeyes do
  it "has a valid localizations_repo key" do
    expect(Nabokov::NabokovfileKeyes.localizations_repo).to eql("localizations_repo")
  end

  it "has a valid localizations_repo_url key" do
    expect(Nabokov::NabokovfileKeyes.localizations_repo_url).to eql("url")
  end

  it "has a valid localizations_repo_master_branch key" do
    expect(Nabokov::NabokovfileKeyes.localizations_repo_master_branch).to eql("master_branch")
  end

  it "has a valid git_repo_master_branch key" do
    expect(Nabokov::NabokovfileKeyes.localizations_repo_master_branch).to eql("master_branch")
  end

  it "has a valid project_repo key" do
    expect(Nabokov::NabokovfileKeyes.project_repo).to eql("project_repo")
  end

  it "has a valid project_local_path key" do
    expect(Nabokov::NabokovfileKeyes.project_local_path).to eql("local_path")
  end

  it "has a valid project_localization_file_paths key" do
    expect(Nabokov::NabokovfileKeyes.project_localization_file_paths).to eql("localizations")
  end
end
