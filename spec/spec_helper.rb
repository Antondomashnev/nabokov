$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

def prepare_repo(future_repo_local_path, initial_repo_fixtures)
  FileUtils.mkdir_p(future_repo_local_path)
  repo = Git.init(future_repo_local_path)
  repo.config("user.name", "nabokov")
  repo.config("user.email", "nabokov@nabokov.com")
  FileUtils.cp_r(initial_repo_fixtures, future_repo_local_path)
  repo.add
  repo.commit("initial commit")
end
