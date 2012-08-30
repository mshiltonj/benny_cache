#!/usr/bin/env rake
require 'rspec'
require "bundler/gem_tasks"
require 'rspec/core/rake_task'


RSpec::Core::RakeTask.new('spec')

namespace :spec do
  desc "Create rspec coverage"
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['spec'].execute
  end
end
