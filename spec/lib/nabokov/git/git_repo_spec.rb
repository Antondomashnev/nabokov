require 'nabokov/git/git_repo'
require 'git'

describe Nabokov::GitRepo do
  describe "initialization" do
    it "stores remote url after initialization" do
      git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git')
      expect(git_repo.remote_url).to eql("https://github.com/Antondomashnev/nabokov_example.git")
    end
  end

  describe "clone" do
    before do
      @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git')
    end

    it "clones the repo from the initialization remote url" do
      allow(Git).to receive(:clone).with("https://github.com/Antondomashnev/nabokov_example.git", anything, anything)
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

    it "returns tocal path under checkout directory in temp with the folder name starts with nabokov prefix" do
      expect(@git_repo.local_path).to start_with("/tmp/checkout/nabokov_")
    end
  end

  describe "add" do

    context "validation" do

      before do
        @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git')
      end

      it "raises an error if there is not file to add at the given path" do
        expect { @git_repo.add("spec/fixtures/qq.strings") }.to raise_error("Could not find any file to add at path 'spec/fixtures/qq.strings'")
      end

      it "raises an error if the repo has not beed cloned before" do
        expect { @git_repo.add("spec/fixtures/de.strings") }.to raise_error("'git' is not cloned yet, please call 'clone' before adding new files to the index")
      end

    end

    it "adds file at the given path to the git repo index" do
      underlying_git_repo = object_double(Git.init('spec/fixtures/test_git_repo_add'))
      expect(underlying_git_repo).to receive(:add).with("spec/fixtures/test_git_repo_add/fr.strings")
      @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git', underlying_git_repo)
      @git_repo.add("spec/fixtures/test_git_repo_add/fr.strings")
    end

  end

  describe "commit" do

    context "validation" do

      before do
        @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git')
      end

      it "raises an error if the repo has not beed cloned before" do
        expect { @git_repo.commit }.to raise_error("'git' is not cloned yet, please call 'clone' before commiting new files")
      end

    end

    it "makes a commit with correct message" do
      underlying_git_repo = object_double(Git.init('spec/fixtures/test_git_repo_add'))
      expect(underlying_git_repo).to receive(:commit).with("Automatic commit by nabokov")
      @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git', underlying_git_repo)
      @git_repo.commit
    end

  end

  describe "push" do

    context "validation" do

      before do
        @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git')
      end

      it "raises an error if the repo has not beed cloned before" do
        expect { @git_repo.push }.to raise_error("'git' is not cloned yet, please call 'clone' before pushing any changes to remote")
      end

    end

    it "makes a push to the remote" do
      underlying_git_repo = object_double(Git.init('spec/fixtures/test_git_repo_add'))
      expect(underlying_git_repo).to receive(:push)
      @git_repo = Nabokov::GitRepo.new('https://github.com/Antondomashnev/nabokov_example.git', underlying_git_repo)
      @git_repo.push
    end

  end

end
