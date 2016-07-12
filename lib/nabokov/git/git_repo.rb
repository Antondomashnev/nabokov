require 'git'

module Nabokov
  class GitRepo

    attr_accessor :remote_url, :local_path

    def initialize(remote_url)
      self.remote_url = remote_url
      self.local_path = local_parent_folder_path + local_folder_name
    end

    def clone
      @git_repo ||= Git.clone(self.remote_url, local_folder_name, :path => local_parent_folder_path)
    end

    private

    def local_parent_folder_path
      @local_parent_folder_path ||= "/tmp/checkout/"
    end

    def local_folder_name
      @local_folder_name ||= "nabokov_#{SecureRandom.uuid}"
    end

  end
end
