# frozen_string_literal: true
require 'rubocop/rake_task'
require 'rake/testtask'

RuboCop::RakeTask.new

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
end

task default: %w(test rubocop)
