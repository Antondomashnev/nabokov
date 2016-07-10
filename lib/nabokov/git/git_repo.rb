require 'git'

module Nabokov
  class GitRepo

    attr_accessor :remote_url

    def initialize(remote_url)
      self.remote_url = remote_url
    end

    def clone
      @git_repo ||= Git.clone(self.remote_url, local_name, :path => local_path)
    end

    private

    def local_path
      @local_path ||= "/tmp/checkout/"
    end

    def local_name
      @local_repo_name ||= "nabokov_#{SecureRandom.uuid}"
    end

  end
end
