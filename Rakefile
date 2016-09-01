require "bundler/gem_tasks"
require "rubocop/rake_task"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:specs)
rescue LoadError
  puts "Please use `bundle exec` to get all the rake commands"
end

task default: :spec

desc "Nabokov's tests"
task :spec do
  Rake::Task["specs"].invoke
  Rake::Task["rubocop"].invoke
end

desc "Run RuboCop on the lib/specs directory"
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = Dir.glob(["lib/**/*.rb", "spec/**/*.rb"]) - Dir.glob(["spec/fixtures/**/*"])
end
