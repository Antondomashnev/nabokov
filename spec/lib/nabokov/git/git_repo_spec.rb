require 'nabokov/git/git_repo'
require 'git'

describe Nabokov::GitRepo do
  describe "initialization" do
    it "stores remote url after initialization" do
      git_repo = Nabokov::GitRepo.new('https://github.com/nabokov/nabokov.git')
      expect(git_repo.remote_url).to eql("https://github.com/nabokov/nabokov.git")
    end
  end

  describe "clone" do
    before do
      @git_repo = Nabokov::GitRepo.new('https://github.com/nabokov/nabokov.git')
    end

    it "clones the repo from the initialization remote url" do
      allow(Git).to receive(:clone).with("https://github.com/nabokov/nabokov.git", anything, anything)
      @git_repo.clone
    end

    it "clones the repo with the localname with nabokov prefix" do
      allow(Git).to receive(:clone).with(anything, /^nabokov_/, anything)
      @git_repo.clone
    end

    it "clones the repo to the local path in tmp/checkout folder" do
      allow(Git).to receive(:clone).with(anything, anything, :path => "/tmp/checkout/")
      @git_repo.clone
    end

  end
end
