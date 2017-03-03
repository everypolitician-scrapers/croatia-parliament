# frozen_string_literal: true
require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'scraper_test'
ScraperTest::RakeTask.new.install_tasks

task default: %w(rubocop test)
