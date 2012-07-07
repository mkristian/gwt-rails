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
      #class_option :session,      :type => :boolean, :default => false
      class_option :gin,           :type => :boolean, :default => false
      class_option :serializer,    :type => :boolean, :default => false
      class_option :optimistic,    :type => :boolean, :default => false
      class_option :timestamps,    :type => :boolean, :default => false
      class_option :menu,          :type => :boolean, :default => false
      #class_option :remote_users, :type => :boolean, :default => false
     
      def setup_options
        super
      end

      def name
        gwt_module_name
      end

      def create_gwt_yml_file
        file = Tempfile.new('gwt')
        begin
          opts = self.options.dup
          opts[:model] = true
          opts[:rest_service] = true
          file.write(opts.to_yaml.sub(/---.*\n/, ''))
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
          unless File.read('.gitignore') =~ /^target/
            File.open('.gitignore', 'a') { |f| f.puts 'target/' }
          end
          unless File.read('.gitignore') =~ /^\*pom/
            File.open('.gitignore', 'a') { |f| f.puts '*pom' }
          end
        end
      end

      def create_entry_point_file
        template('EntryPoint.java', 
                 File.join(java_root, 
                           base_package.gsub(/\./, '/'), 
                           "#{application_class_name}EntryPoint.java"))
        template("SimpleGwtApplication.java", 
                 File.join(java_root, 
                           base_package.gsub(/\./, '/'), 
                           "#{application_class_name}Application.java"))
      end

      def create_managed_files
        path = managed_package.gsub(/\./, '/')
        if options[:gin]
          template('GinModule.java', 
                   File.join(java_root, path, 
                             "#{application_class_name}Module.java"))
        end
        if options[:place]
          template('PlaceHistoryMapper.java', 
                   File.join(java_root, path, 
                             "#{application_class_name}PlaceHistoryMapper.java"))
          template('ActivityFactory.java', 
                    File.join(java_root, path, 
                              'ActivityFactory.java'))
        end
        if options[:menu]
          template('Menu.java', 
                   File.join(java_root, path, 
                             "#{application_class_name}Menu.java"))
        end
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
        if options[:session]
          template 'SessionActivityPlaceActivityMapper.java', 
                        File.join(java_root, path, 
                                  'SessionActivityPlaceActivityMapper.java')
          template 'BreadCrumbsPanel.java', 
                        File.join(java_root, path, 
                                  'BreadCrumbsPanel.java')          
        end
      end

      def create_session_files
        if options[:session]
          template 'LoginActivity.java',
                        File.join(java_root, activities_package.gsub(/\./, '/'),
                                  'LoginActivity.java')
          template 'User.java',
                        File.join(java_root, models_package.gsub(/\./, '/'),
                                  'User.java')
          template 'LoginPlace.java',
                        File.join(java_root, places_package.gsub(/\./, '/'),
                                  'LoginPlace.java')
          template 'SessionRestService.java',
                        File.join(java_root, restservices_package.gsub(/\./, '/'),
                                  'SessionRestService.java')
          template 'LoginViewImpl.java',
                        File.join(java_root, views_package.gsub(/\./, '/'),
                                  'LoginViewImpl.java')
          template 'LoginView.ui.xml',
                        File.join(java_root, views_package.gsub(/\./, '/'),
                                  'LoginView.ui.xml')
        end
      end

      def create_html
        template 'page.html', File.join('public', "#{application_name}.html")
        template('gwt.css', 
                 File.join('public', 'stylesheets', "#{application_name}.css"))
        template 'htaccess', File.join('public', application_class_name, '.htaccess')
      end

      def create_web_xml
        template 'web.xml', File.join('public', 'WEB-INF', 'web.xml')
        template 'gitignore', File.join('public', 'WEB-INF', '.gitignore')
      end

#      def add_gems
#        gem 'ixtlan-core'
#      end

      def add_raketask
        if options[:remote_user]
          prepend_file 'Rakefile', '#-*- mode: ruby -*-\n'
          append_file 'Rakefile', <<-EOF

desc 'triggers the heartbeat request (user updates)'
task :heartbeat => [:environment] do
    heartbeat = Heartbeat.new
    heartbeat.beat

    puts "\#{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')} - \#{heartbeat}"
end
# vim: syntax=Ruby
EOF
        end
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
          app_controller.sub! /ActionController::Base$/, <<SESSION

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound do
    head :not_found
  end
SESSION
        end
        if options[:optimistic]
          unless app_controller =~ /head\s+:conflict/
            changed = true
            app_controller.sub! /rescue_from/, 'rescue_from Ixtlan::Optimistic::ObjectStaleException do
    head :conflict
  end

  rescue_from'
          end
        end  
        if options[:serializer]
          unless app_controller =~ /def\s+cleanup/
            changed = true
            app_controller.sub! /^end\s*$/, <<SESSION
  protected

  before_filter :cleanup

  def cleanup(model)
    # compensate the shortcoming of the incoming json/xml
    model ||= []
    model.delete :id
    model.delete :created_at
    params[:updated_at] ||= model.delete :updated_at
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

      def create_rails_session_files
        if options[:session]
          template 'sessions_controller.rb', File.join('app', 'controllers', 'sessions_controller.rb')
          file = File.join('config', 'environments', 'development.rb')
          development = File.read(file)
          changed = false
          unless development =~ /config.remote_service_url/
            changed = true
            development.sub! /^end\s*$/, <<ENV

  if ENV['SSO'] == 'true' || ENV['SSO'] == ''
    config.remote_service_url = 'http://localhost:3000'
    config.remote_token = 'be happy'
  end
end
ENV
          end
          if changed
            File.open(file, 'w') { |f| f.print development }
            log 'changed', file
          else
            log 'unchanged', file
          end
          file = File.join('app', 'controllers', 'application_controller.rb')
          app_controller = File.read(file)
          changed = false
          unless app_controller =~ /def\s+current_user/
            changed = true
            app_controller.sub! /^end\s*$/, <<SESSION

  protected

  def current_user(user = nil)
    session['user'] = user if user
    session['user']
  end
end
SESSION
          end
          template 'authentication.rb', File.join('app', 'models', 'authentication.rb')
          template 'group.rb', File.join('app', 'models', 'group.rb')          
          template 'session.rb', File.join('app', 'models', 'session.rb')
          template 'user.rb', File.join('app', 'models', 'user.rb')
          if options[:remote_users]
            template 'remote_user.rb', File.join('app', 'models', 'remote_user.rb')
            template 'application.rb', File.join('app', 'models', 'application.rb')
            template 'ApplicationLinksPanel.java', File.join(java_root, base_package.gsub(/\./, '/'), 'ApplicationLinksPanel.java')
            template 'Application.java', File.join(java_root, models_package.gsub(/\./, '/'), 'Application.java')
            template 'create_users.rb', File.join('db', 'migrate', '0_create_users.rb')
            template 'heartbeat.rb', File.join('lib', 'heartbeat.rb')
          end
          FileUtils.mv(File.join('db', 'seeds.rb'), File.join('db', 'seeds-old.rb'))
          template 'seeds.rb', File.join('db', 'seeds.rb')
          route <<ROUTE
resource :session do
    member do
      post :reset_password
    end
  end
ROUTE
          gem 'ixtlan-core'
          gem 'ixtlan-session-timeout'
          gem 'ixtlan-guard'
          # needs to be in Gemfile to have jruby find the gem
          gem 'jruby-openssl', '~> 0.7.4', :platforms => :jruby
        end
      end
      
      def base_package
        name + '.client'
      end

    end
  end
end
