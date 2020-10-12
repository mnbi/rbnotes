require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

task test: [:clean, :setup_test]

desc "Setup test data"
task :setup_test do
  print "Set up to execute tests..."
  load("test/fixtures/setup_test_repo.rb", true)
  puts "done."
end

CLEAN << "test/sandbox"
CLOBBER << "test/fixtures/test_repo"
