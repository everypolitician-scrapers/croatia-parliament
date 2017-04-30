# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'
require 'scraper_test'
RuboCop::RakeTask.new

ScraperTest::RakeTask.new.install_tasks

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
end

task default: %w[rubocop test]
