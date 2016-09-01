require "bundler/gem_tasks"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:specs)

task default: :spec

desc "Nabokov's tests"
task :spec do
  Rake::Task["specs"].invoke
  Rake::Task["rubocop"].invoke
end
