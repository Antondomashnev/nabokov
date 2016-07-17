require 'git'
require 'securerandom'

module Nabokov
  class GitRepo

    attr_accessor :remote_url, :local_path

    def initialize(remote_url, git_repo = nil)
      @git_repo = git_repo
      self.remote_url = remote_url
      self.local_path = local_parent_folder_path + local_folder_name
    end

    def clone
      @git_repo ||= Git.clone(self.remote_url, local_folder_name, :path => local_parent_folder_path)
    end

    def add(file_path)
      raise "Could not find any file to add at path '#{file_path}'" unless File.exist?(file_path)
      raise "'git' is not cloned yet, please call 'clone' before adding new files to the index" if @git_repo.nil?

      @git_repo.add(file_path)
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
