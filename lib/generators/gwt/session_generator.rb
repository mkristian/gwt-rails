require 'rails/generators/resource_helpers'
require 'generators/base'
require 'tempfile'
module Gwt
  module Generators
    class SessionGenerator < Base

      source_root File.expand_path(File.join('templates', 'session'), File.dirname(__FILE__))

      arguments.clear # clear name argument from NamedBase
      
      argument :gwt_module_name,   :type => :string, :required => true

      class_option :place,         :type => :boolean, :default => false
      class_option :gin,           :type => :boolean, :default => false
      class_option :serializer,    :type => :boolean, :default => false
      class_option :optimistic,    :type => :boolean, :default => false
      class_option :timestamps,    :type => :boolean, :default => false
      class_option :menu,          :type => :boolean, :default => false
      class_option :remote_users,  :type => :boolean, :default => false
      class_option :managed_files, :type => :boolean, :default => true
     
      def setup_options
        super
      end

      def name
        gwt_module_name
      end

      def create_entry_point_file
        template("GwtApplication.java", 
                 File.join(java_root, 
                           base_package.gsub(/\./, '/'), 
                           "#{application_class_name}Application.java"))
      end

      def create_managed_files
        path = base_package.gsub(/\./, '/')
        if options[:gin]
          template('GinModule.java', 
                   File.join(java_root, path, 
                             "#{application_class_name}GinModule.java"))
        end
        unless options[:managed_files]
          path = managed_package.gsub(/\./, '/')
          if options[:gin]
            template('ManagedGinModule.java', 
                     File.join(java_root, path, 
                               "ManagedGinModule.java"))
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
      end

      def create_places_files
        path = base_package.gsub(/\./, '/')
        if options[:place]
          template('SessionActivityPlaceActivityMapper.java', 
                   File.join(java_root, 
                             path, 
                             'SessionActivityPlaceActivityMapper.java'))
        end
      end

      def create_breadcrumbs_files
        path = base_package.gsub(/\./, '/')
        if options[:menu]
          template('BreadCrumbsPanel.java', 
                   File.join(java_root, 
                             path, 
                             'BreadCrumbsPanel.java'))
        end
      end      

      def create_session_files
        template('LoginActivity.java',
                 File.join(java_root, 
                           activities_package.gsub(/\./, '/'),
                           'LoginActivity.java'))
        template('LoginPresenter.java',
                 File.join(java_root, 
                           presenters_package.gsub(/\./, '/'),
                           'LoginPresenter.java'))
        template('User.java',
                 File.join(java_root, 
                           models_package.gsub(/\./, '/'),
                           'User.java'))
          template('LoginPlace.java',
                   File.join(java_root, 
                             places_package.gsub(/\./, '/'),
                             'LoginPlace.java'))
          template('SessionRestService.java',
                   File.join(java_root, 
                             restservices_package.gsub(/\./, '/'),
                             'SessionRestService.java'))
          template('LoginViewImpl.java',
                   File.join(java_root, 
                             views_package.gsub(/\./, '/'),
                             'LoginViewImpl.java'))
          template('LoginView.ui.xml',
                   File.join(java_root, 
                             views_package.gsub(/\./, '/'),
                             'LoginView.ui.xml'))
      end

      def create_rails_session_files
        template 'sessions_controller.rb', File.join('app', 'controllers', 'sessions_controller.rb')
        if options[:remote_users]
          file = File.join('config', 'environments', 'development.rb')
          development = File.read(file)
          changed = false
          unless development =~ /config.remote_service_url/
            changed = true
            development.sub! /^end\s*$/, <<ENV

  config.remote_service_url = 'http://localhost:3000'
  config.remote_service_token = 'be happy'
end
ENV
          end
          if changed
            File.open(file, 'w') { |f| f.print development }
            log 'changed', file
          else
            log 'unchanged', file
          end
        end
        file = File.join('app', 'controllers', 'application_controller.rb')
        append_file file,  <<SESSION

  protected

  def current_user(user = nil)    if user
      session['user'] = {'id' => user.id, 'groups' => user.groups}
      @_current_user = user
    else
      @_current_user ||= begin
                           data = session['user']
                           if data
                             u = User.#{ defined?(DataMapper) ? 'get!' : 'find' }(data['id'])
                             u.groups = data['groups']
                             u
                           end
                         end            
    end
  end
end
SESSION

        template 'authentication.rb', File.join('app', 'models', 'authentication.rb')
        template 'group.rb', File.join('app', 'models', 'group.rb')
        template 'session.rb', File.join('app', 'models', 'session.rb')
        if options[:serializer]
          template 'session_serializer.rb', File.join('app', 'serializers', 'session_serializer.rb')
        else
          say_status 'warning', 'there is no proper serialization in place for the session model', :red
        end
        user_file = 
          if ! options[:remote_users]
            'user_model.rb'
          elsif defined? DataMapper
            'user_datamapper.rb'
          else
            'user_activerecord.rb'
          end
        template user_file, File.join('app', 'models', 'user.rb')
        if options[:remote_users]
          template 'remote_user.rb', File.join('app', 'models', 'remote_user.rb')
          template 'application.rb', File.join('app', 'models', 'application.rb')
          template 'ApplicationLinksPanel.java', File.join(java_root, base_package.gsub(/\./, '/'), 'ApplicationLinksPanel.java')
          template 'Application.java', File.join(java_root, models_package.gsub(/\./, '/'), 'Application.java')
          unless defined? DataMapper
            template 'create_users.rb', File.join('db', 'migrate', '0_create_users.rb')
          end
          template 'heartbeat.rb', File.join('lib', 'heartbeat.rb')
        end
        FileUtils.mv(File.join('db', 'seeds.rb'), File.join('db', 'seeds.rb~')) unless File.exists?(File.join('db', 'seeds.rb~'))

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

      def base_package
        @base_package ||= name + '.client'
      end
    end
  end
end
