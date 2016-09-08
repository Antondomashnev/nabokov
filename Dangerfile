has_app_changes = !git.modified_files.grep(/lib/).empty?
has_test_changes = !git.modified_files.grep(/spec/).empty?

if has_app_changes && !has_test_changes
  warn("Tests were not updated")
end

if github.pr_title.length < 5
  fail "Please provide a meaningful Pull Request title"
end

if github.pr_body.length < 5
  fail "Please provide a summary in the Pull Request description"
end

declared_trivial = (github.pr_title + github.pr_body).include?("#trivial") || !has_app_changes
changelog.check unless declared_trivial

protected_files = ["nabokov.gemspec", "Dangerfile", "Gemfile", ".gitignore", ".travis.yml", ".rubocop.yml", "Rakefile"]
protected_files.each do |file|
  files.protect_files(path: file, message: "#{file} modified", fail_build: false)
end

junit.parse "junit-results.xml"
junit.headers = [:file, :name]
junit.report
