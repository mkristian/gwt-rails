gem 'gwt-rails'

unless defined? JRUBY_VERSION
  apply 'http://jruby.org/templates/default.rb'

  unless options[:sprockets]
    gsub_file "Gemfile", /^# the javascript engine for execjs gem
platforms :jruby do
  group :assets do
    gem 'therubyrhino'
  end
end
/, ''
  end
end

if ENV['GWT_APP_GEN_BUNDLE_INSTALL'] == 'true'
  command = 'install'
  say_status :run, "bundle #{command}"
  print `"#{Gem.ruby}" -rubygems "#{Gem.bin_path('bundler', 'bundle')}" #{command}`

  unless defined? JRUBY_VERSION
    say ''
    say ''
    say 'you might want to run "bundle install" with jruby to have the Gemfile setup for both platforms (MRI, JRuby)'
  end
end
say ''
say ''
say 'please use the following generator to setup a base application:'
say "\trails g gwt:setup JAVA_PACKAGE_FOR_GWT_APP", :blue
say 'for all the possible options use'
say "\trails g gwt:setup", :blue
say ''
say ''

if defined? JRUBY_VERSION
  say ''
  say 'you used JRuby!'
  say 'consider redo the setup with MRI. command line execution wiith MRI is significantly faster and the final application will run on bath platforms (unless you use jar libraries within rails).'
  say ''
end
