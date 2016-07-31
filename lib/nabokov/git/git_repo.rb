require 'git'
require 'uri'
require 'securerandom'
require 'pathname'

module Nabokov
  class GitRepo

    attr_accessor :remote_url, :local_path

    def initialize(remote_url, local_path, git_repo = nil)
      raise "remote_url is a required parameter" if remote_url.nil?
      raise "local_path is a required parameter" if local_path.nil?
      @local_pathname = Pathname.new(local_path)
      @git_repo = git_repo
      self.remote_url = remote_url
      self.local_path = local_path
    end

    def clone
      raise "Git repo has been already cloned at '#{self.local_path}', please use 'init' instead" if repo_exist_at_local_path
      @git_repo ||= Git.clone(self.remote_url, @local_pathname.basename.to_s, :path => @local_pathname.parent.to_s)
    end

    def init
      raise "Git repo has not been cloned yet from '#{self.remote_url}', please use 'clone' instead" unless repo_exist_at_local_path
      @git_repo ||= Git.init(self.local_path)
    end

    def add(file_path)
      raise "Could not find any file to add at path '#{file_path}'" unless File.exist?(file_path)
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before adding new files to the index" if @git_repo.nil?
      @git_repo.add(file_path)
    end

    def commit(message = nil)
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before commiting new files" if @git_repo.nil?
      message ||= "Automatic commit by nabokov"
      @git_repo.commit(message)
    end

    def push
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before pushing any changes to remote" if @git_repo.nil?
      @git_repo.push
    end

    def pull
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before pushing any changes to remote" if @git_repo.nil?
      @git_repo.pull
    end

    private

    def repo_exist_at_local_path
      Dir.exists?(self.local_path)
    end

  end
end
