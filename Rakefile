#-*- mode: ruby -*-

require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'fileutils'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

task :default => [:features]

task :clean do
  FileUtils.rm_rf('target')
end

# vim: syntax=Ruby
