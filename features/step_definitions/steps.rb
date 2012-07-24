require 'fileutils'
require 'ruby-maven'

def rmvn
  @rmvn ||= begin
              rmvn = Maven::RubyMaven.new
              # copy the jruby version and the ruby version (1.8 or 1.9)
              # to be used by maven process
              rmvn.options['-Djruby.version'] = JRUBY_VERSION if defined? JRUBY_VERSION
              
              rversion = RUBY_VERSION  =~ /^1.8./ ? '--1.8': '--1.9'
              rmvn.options['-Djruby.switches'] = rversion
              rmvn.options['-l'] = 'output.log'
              # offline
              #rmvn.options['-o'] = nil
              # full maven log
              #rmvn.options['-X'] = nil
              # jruby related debug log
              rmvn.options['-Djruby.verbose'] = true
              gems = File.expand_path(File.join('target', 'rubygems'))
              rmvn.options['-Dgem.home'] = ENV['GEM_HOME'] || gems
              rmvn.options['-Dgem.path'] = ENV['GEM_PATH'] || gems
              rmvn
            end
end

def copy_to(name)
  dir = 'app'
  path = File.join('it', dir)
  base = File.join('target', dir)
  @target = File.join(base, name)
  FileUtils.rm_rf(@target)
  FileUtils.mkdir_p(base)
  FileUtils.cp_r(path, @target)
end

def copy_mavenfile
  path = File.join('it', 'app', 'Mavenfile')
  FileUtils.cp_r(path, @target)
end

def exec(*args)
  succeeded = rmvn.exec_in(@target, *args)
  unless succeeded
    puts File.read(File.join(@target, 'output.log'))
     raise 'failure' 
   end
end

def exec_line(line)
  puts "\t#{line}"
  exec(line.split(/\s+/))
end


def scaffold(name, args = '')
  ['', '--read-only','--singleton', '--read-only --singleton'].each do |extra|
    n = (name + '_' + extra.sub(/ /, '_').gsub(/-/, '')).sub(/_$/, '')
    line = "rails generate scaffold #{n} color:string #{extra} #{args}"
    exec_line line
  end
end

Given /^application and setup GWT with "([^\"]*)"$/ do |args|
  name = args.gsub(/--/, '').gsub(/-/,'_').gsub(/ /, '_')
  copy_to(name)
  line = "rails generate gwt:setup com.example #{args} --force"
  exec_line(line)
end

Given /^application setup with "([^\"]*)"$/ do |args|
  name = args.gsub(/--/, '').gsub(/-/,'_').gsub(/ /, '_')
  copy_to(name)
  line = "rails generate gwt:setup com.example #{args} --template-engine=false --force"
  exec_line(line)
end

When /^scaffold a resource "([^\"]*)"$/ do |name|
  scaffold(name)
end

When /^scaffold a resource "([^\"]*)" with "([^\"]*)"$/ do |name, args|
  scaffold(name, args)
end

Given /^execute "([^\"]*)"$/ do |args|
  exec_line(args)
end

Then /^gwt compile succeeds$/ do
  exec('compile', 'gwt:compile')#, '-Dgwt.compiler.strict')
end

Then /^"([^\"]*)" succeeds\.$/ do |args|
  path = File.join('it', 'app', 'Mavenfile')
  FileUtils.cp_r(path, @target)

  webxml = File.join(@target, 'public', 'WEB-INF', 'web.xml')
  content = File.read(webxml)
  content.sub!(/.\/target\/rubygems/, rmvn.options['-Dgem.path'])
  File.open(webxml, 'w') { |f| f.puts content }

  ENV['RAKE_TASK'] = args.sub(/rake\s+/, '')
  ENV['TEST_PORT'] = '8080'
  exec('verify', '-Dmaven.test.skip')#, '-Dgwt.compiler.strict')
  puts "\t#{args}"
end
