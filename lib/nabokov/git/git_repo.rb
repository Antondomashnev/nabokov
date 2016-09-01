require "git"
require "uri"
require "securerandom"
require "pathname"

module Nabokov
  class GitRepo
    attr_accessor :remote_url, :local_path

    def initialize(local_path, remote_url = nil, git_repo = nil)
      raise "local_path is a required parameter" if local_path.nil?
      expanded_local_path = File.expand_path(local_path)
      @local_pathname = Pathname.new(expanded_local_path)
      @git_repo = git_repo
      self.remote_url = remote_url
      self.local_path = expanded_local_path
    end

    def clone
      raise "Git repo has been already cloned at '#{self.local_path}', please use 'init' instead" if repo_exist_at_local_path
      @git_repo ||= Git.clone(self.remote_url, @local_pathname.basename.to_s, path: @local_pathname.parent.to_s)
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

    def checkout_branch(name)
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before checkouting any branch" if @git_repo.nil?
      raise "branch name could not be nil or zero length" if name.nil? || name.length.zero?
      if @git_repo.is_branch?(name)
        @git_repo.checkout(name)
      else
        @git_repo.checkout(name, { new_branch: true })
      end
    end

    def delete_branch(name)
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before deleting any branch" if @git_repo.nil?
      raise "branch name could not be nil or zero length" if name.nil? || name.length.zero?
      @git_repo.branch(name).delete
    end

    def merge_branches(original_branch, branch_to_be_merged)
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before merging any branches" if @git_repo.nil?
      raise "original branch name could not be nil or zero length" if original_branch.nil? || original_branch.length.zero?
      raise "branch to be merged in name could not be nil or zero length" if branch_to_be_merged.nil? || branch_to_be_merged.length.zero?
      @git_repo.branch(original_branch).merge(@git_repo.branch(branch_to_be_merged))
    end

    def changes?
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before checking if the git repo has changes" if @git_repo.nil?
      return true if @git_repo.status.deleted.count > 0
      return true if @git_repo.status.added.count > 0
      return true if @git_repo.status.changed.count > 0
      false
    end

    def unfinished_merge?
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before checking if the git repo has unfinished merge" if @git_repo.nil?
      return @git_repo.has_unmerged_files?
    end

    def current_branch
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before getting the current branch" if @git_repo.nil?
      return @git_repo.current_branch
    end

    def abort_merge
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before aborting merge" if @git_repo.nil?
      raise "nothing to abort - git repo doesn't have unfinished merge" unless self.unfinished_merge?
      @git_repo.abort_merge
    end

    def unmerged_files
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before asking for unmerged files" if @git_repo.nil?
      return [] unless @git_repo.has_unmerged_files?
      conflicted_files = []
      @git_repo.each_conflict do |file, your_version, their_version|
        conflicted_files << file
      end
      conflicted_files
    end

    def reset_to_commit(commit_sha, options = {})
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before resetting" if @git_repo.nil?
      raise "'commit' is a required parameter and could not be nil" if commit_sha.nil?
      if options[:hard]
        @git_repo.reset_hard(commit_sha)
      else
        @git_repo.reset(commit_sha)
      end
    end

    def log(number_of_commits)
      raise "'git' is not initialized yet, please call either 'clone' or 'init' before getting the log" if @git_repo.nil?
      commits = @git_repo.log(number_of_commits)
      commits.map(&:sha)
    end

    private

    def repo_exist_at_local_path
      Dir.exist?(self.local_path)
    end
  end
end
