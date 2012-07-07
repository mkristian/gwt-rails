# -*- coding: utf-8 -*-
require File.expand_path('lib/gwt/rails/version.rb')
Gem::Specification.new do |s|
  s.name = 'gwt-rails'
  s.version = Gwt::Rails::VERSION.dup

  s.summary = 'tools for developing GWT apps with rails backend'
  s.description = ''
  s.homepage = 'http://github.com/mkristian/gwt-rails'

  s.authors = ['Kristian Meier']
  s.email = ['m.kristian@web.de']

  s.bindir = "bin"
  s.executables = ['gwt']

  s.files += Dir['bin/*']
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.files += Dir['MIT-LICENSE'] + Dir['*.md']
  s.test_files += Dir['spec/**/*_spec.rb']
  s.add_runtime_dependency 'ruby-maven', '3.0.4.0.29.0'
  s.add_development_dependency 'rake', '0.9.2.2'
  s.add_development_dependency 'cucumber', '~> 1.1.9'
end
