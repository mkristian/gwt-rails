require 'generators/setup_options'
module Gwt
  module Model
    
    def self.included(base)
      base.class_eval do

        def self.source_root          
          File.expand_path(File.join('generators', 
                                     'templates',
                                     defined?(DataMapper) ? 'datamapper' : 'activerecord'), 
                           File.dirname(__FILE__))
        end

        class_option :singleton,   :type => :boolean, :default => false
        class_option :optimistic,  :type => :boolean, :default => false
        class_option :modified_by, :type => :string,  :desc => 'class name for the modified_by field. GWT class must implement interface IsUser'

        alias :options_old :options

        no_tasks do

          include Gwt::Generators::SetupOptions

          def options
            # replace options with defaults from yml file
            @__options ||= 
              begin
                setup_options(options_old)
              end
          end
        end

      end
    end
  end
end

class Railtie < Rails::Railtie

  gmethod = config.respond_to?(:generators)? :generators : :app_generators
  config.after_initialize do |app|
    # monkey patch generator only when used
    if ARGV[0] == 'scaffold' || ARGV[0] == 'model'

      begin
        # load lazy to avoid strange effects
        require 'rails/generators/active_record/model/model_generator'
        
        ActiveRecord::Generators::ModelGenerator.send :include,  Gwt::Model
      rescue LoadError
        begin
          # load lazy to avoid strange effects
          require 'generators/data_mapper/model/model_generator'
          DataMapper::Generators::ModelGenerator.send :include,  Gwt::Model
        rescue LoadError
          warn "not datamapper and not activerecord"
        end
      end
    end
  end
end
