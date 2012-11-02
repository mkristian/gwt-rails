require 'rails/generators/resource_helpers'
require 'generators/base'
require 'tempfile'
module Gwt
  module Generators
    class SetupGenerator < Base

      source_root File.expand_path('templates', File.dirname(__FILE__))

      arguments.clear # clear name argument from NamedBase
      
      argument :gwt_module_name,   :type => :string, :required => true

      class_option :place,         :type => :boolean, :default => false
      class_option :gin,           :type => :boolean, :default => false
      class_option :serializer,    :type => :boolean, :default => false
      class_option :optimistic,    :type => :boolean, :default => false
      class_option :timestamps,    :type => :boolean, :default => false
      class_option :menu,          :type => :boolean, :default => false
     
      def setup_options
        super
      end

      def name
        gwt_module_name
      end

      def maybe_warn
        if options[:optimistic] && !options[:serializer]
          say_status :warn, "the optimistic find/get needs a more precise datatime/time then the default json formater/parser produces. please configure it to use at least milliseconds (javascript is limited to milliseconds). see ixtlan-babel gem for a working format.", :red
        end
        if options[:singleton] && !options[:serializer]
          say_status :warn, "singleton have an id in the database but the GWT model does not. i.e. you need to filter the id on json serialization.", :red
        end
      end

      def create_gwt_yml_file
        file = Tempfile.new('gwt')
        begin
          opts = self.options.dup
          opts[:timestamps] = true if opts[:timestamps].nil?
          opts[:migration] = true if opts[:migration].nil?
          opts[:model] = true
          opts[:rest_service] = true
          opts[:managed_files] = false
          opts.keys.sort.each do |k|
            file.puts "#{k}: #{opts[k]}" unless k =~ /session/
          end
          file.close
          template file.path, File.join('config', 'gwt.yml')
        ensure
          file.close
          file.unlink   # deletes the temp file
        end
      end

      def create_module_file
        template 'Module.gwt.xml', File.join(java_root, name.gsub(/\./, '/'), "#{application_class_name}.gwt.xml")
        template 'ModuleDevelopment.gwt.xml', File.join(java_root, name.gsub(/\./, '/'), "#{application_class_name}Development.gwt.xml")
      end

      def create_maven_file
        template 'Mavenfile', 'Mavenfile'
        if File.exists?('.gitignore')
          gitignore = File.read('.gitignore')
          unless gitignore =~ /^target/
            File.open('.gitignore', 'a') { |f| f.puts 'target/' }
          end
          unless gitignore =~ /^\*pom/
            File.open('.gitignore', 'a') { |f| f.puts '.pom.xml' }
          end
          unless gitignore =~ /^gwt-unitCache/
            File.open('.gitignore', 'a') { |f| f.puts 'gwt-unitCache/' }
          end
        end
      end

      def create_entry_point_file
        template('EntryPoint.java', 
                 File.join(java_root, 
                           base_package.gsub(/\./, '/'), 
                           "#{application_class_name}EntryPoint.java"))
        template("GwtApplication.ui.xml", 
                 File.join(java_root, 
                           base_package.gsub(/\./, '/'), 
                           "#{application_class_name}Application.ui.xml"))
      end

      def create_scaffolded_files
        path = base_package.gsub(/\./, '/')
        template('Confirmation.java', 
                 File.join(java_root, path, 
                           "#{application_class_name}Confirmation.java"))
        if options[:view]
          template('ErrorHandler.java', 
                   File.join(java_root, path, 
                             "#{application_class_name}ErrorHandler.java"))
        end
        if options[:place]
          template('ActivityPlaceActivityMapper.java', 
                   File.join(java_root, path, 
                             'ActivityPlaceActivityMapper.java'))
        end
      end

      def create_html
        template 'page.html', File.join('public', "#{application_class_name}.html")
        template('gwt.css', 
                 File.join('public', 'stylesheets', "#{application_name}.css"))
        template 'htaccess', File.join('public', application_class_name, '.htaccess')
      end

      def create_web_xml
        template 'web.xml', File.join('public', 'WEB-INF', 'web.xml')
        template 'gitignore', File.join('public', 'WEB-INF', '.gitignore')
      end

      def create_monkey_patch_responder
        template 'monkey_patch_responder.rb', File.join('config', 'initializers', 'monkey_patch_responder.rb')
      end

      def inject_application_config
        file = File.join('config', 'application.rb')
        if File.read(file) =~ /config.generators\s+do/
          say_status :unchanged, file, :blue
        else
          inject_into_class(file,
                            "Application",
                            <<GENERATORS

    config.generators do |g|
      g.stylesheet_engine false
      g.template_engine 'ui'
      g.assets false
      g.helper false
      g.stylesheets false
      g.scaffold_controller 'gwt'
      g.resource_route 'gwt'
    end

GENERATORS
                            )
        end
      end

      def create_csrf_header
        file = File.join('app', 'controllers', 'application_controller.rb')
        app_controller = File.read(file)
        changed = false
        unless app_controller =~ /respond_to\s+:json/
          changed = true
          not_found = defined?(DataMapper) ? "DataMapper::ObjectNotFoundError" : "ActiveRecord::RecordNotFound"
          app_controller.sub! /ActionController::Base$/, <<SESSION
ActionController::Base

  respond_to :json

  rescue_from #{not_found} do
    head :not_found
  end
SESSION
        end
        if options[:optimistic]
          gem 'ixtlan-optimistic'
          unless app_controller =~ /head\s+:conflict/
            changed = true
            app_controller.sub! /rescue_from/, 'rescue_from Ixtlan::Optimistic::ObjectStaleException do
    head :conflict
  end

  rescue_from'
          end
        end  
        if options[:serializer]||true
          gem 'ixtlan-babel'
          unless app_controller =~ /def\s+cleanup/
            changed = true
            app_controller.sub! /^end\s*$/, <<SESSION

  protected

  before_filter :cleanup

  def updated_at(key = params[:controller])
    @_updated_at ||= (params[key] || {})[:updated_at]
  end

  def cleanup(model)
    # compensate the shortcoming of the incoming json/xml
    model ||= []
    model.delete :id
    model.delete :created_at 
    @_updated_at ||= model.delete :updated_at
  end
end
SESSION
          end
        end
        if options[:serializer]
          unless app_controller =~ /def\s+serializer/
            changed = true
            app_controller.sub! /^end\s*$/, <<SESSION

  protected

  def serializer(resource)
    if resource
      @_factory ||= Ixtlan::Babel::Factory.new
      @_factory.new(resource)
    end
  end
end
SESSION
          end
        end
        unless app_controller =~ /def\s+csrf/
          changed = true
          app_controller.sub! /^end\s*$/, <<SESSION

  private

  after_filter :csrf

  def csrf
    response.header['X-CSRF-Token'] = form_authenticity_token
  end
end
SESSION
        end
        if changed
          File.open(file, 'w') { |f| f.print app_controller }
          say_status :changed, file
        else
          say_status :unchanged, file, :blue
        end
      end
  
      def base_package
        @base_package ||= name + '.client'
      end
      
      hook_for :setup_session, :in => :gwt, :default => :session

      def say_something
        say ''
        say ''
        say 'the file "config/gwt.yml" contains default options for the gwt generators. feel free to change them as needed.'
        say ''
        say ''
      end
    end
  end
end
