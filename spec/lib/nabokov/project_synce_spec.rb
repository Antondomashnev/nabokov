require 'nabokov/commands/syncers/project_syncer'
require 'nabokov/git/git_repo'
require 'nabokov/helpers/merger'
require 'nabokov/helpers/informator'

describe Nabokov::ProjectSyncer do
  before(:each) do
    allow(STDOUT).to receive(:puts)
  end

  it 'is not an abstract command' do
    expect(Nabokov::ProjectSyncer.abstract_command).to be_falsy
  end

  describe "run" do
    
  end
end
