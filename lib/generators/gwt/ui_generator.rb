require 'rails/generators/resource_helpers'
require 'generators/base'
module Gwt
  module Generators
    class UiGenerator < Base

      source_root File.expand_path('templates', File.dirname(__FILE__))

      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type field:belongs_to", :desc => 'if no fields are given and there is a model in RAILS_ROOT/app/models then the attrbutes/properties of the model is the source of the fields'

      class_option :timestamps,   :type => :boolean, :default => true
      class_option :optimistic,   :type => :boolean, :default => false
      class_option :modified_by,  :type => :string,  :desc => 'class name for the modified_by field. GWT class must implement interface IsUser'
      class_option :read_only,    :type => :boolean, :default => false
      class_option :singleton,    :type => :boolean, :default => false
      class_option(:parent,       :type => :string,  
                   :desc => "The parent class for the generated model")
      class_option :model,        :type => :boolean, :default => true
      class_option :rest_service, :type => :boolean, :default => true
      class_option(:cache,        :type => :boolean, :default => false,
                   :desc => 'Uses a cache for loading models. Implies event = true')
      class_option :event,        :type => :boolean, :default => false
      class_option :editor,       :type => :boolean, :default => false
      class_option(:view,         :type => :boolean, :default => false,
                   :desc => 'Simple view classes for manipulating models. Implies editors = true')
      class_option :gin,          :type => :boolean, :default => false

      no_tasks do

        if defined? ActiveRecord

          def parse_attributes! #:nodoc:
            super
            self.options = self.options.dup
            if self.attributes.empty?
              options[:timestamps] = false
              options[:modified_by] = false
              model = name.classify.constantize
              attr = []
              model.columns.each do |col|
                options[:timestamps] = true if [:created_at, :updated_at].member?(col.name.to_sym)
                if col.name != 'id' && (col.name =~ /_id$/).nil? && ! [:created_at, :updated_at].member?(col.name.to_sym)
                  attr << ::Rails::Generators::GeneratedAttribute.parse("#{col.name}:#{col.type}")
                end
              end
              self.options[:singleton] = true if model.respond_to?(:instance)
              self.attributes = attr
p attr
            end
            self.options[:editor] = true if self.options[:view]
            self.options[:event] = true if self.options[:cache]
            self.options.freeze
          end
          
        elsif defined? DataMapper
          DM_MAP = {
            DataMapper::Property::String => :string,
            DataMapper::Property::Integer => :integer,
            DataMapper::Property::DateTime => :datetime,
            DataMapper::Property::Date => :date,          
          }
          
          def parse_attributes! #:nodoc:
            super
            self.options = self.options.dup
            if self.attributes.empty?
              model = name.classify.constantize
              attr = []
              model.properties.each do |prop| 
                options[:timestamps] = true if [:created_at, :updated_at].member?(prop.name)
                if prop.name.to_s != 'id' && (prop.name.to_s =~ /_id$/).nil? && ! [:created_at, :updated_at].member?(prop.name)
                  attr << ::Rails::Generators::GeneratedAttribute.parse("#{prop.name}:#{DM_MAP[prop.class]}")
                end
              end
              model.relationships.each do |rel|
                if rel.child_model_name == model.to_s
                  if rel.name.to_sym == :modified_by
                    self.options[:modified_by] = rel.parent_model_name 
                  else
                    attr << ::Rails::Generators::GeneratedAttribute.parse("#{rel.name}:#{rel.parent_model_name.underscore}:belongs_to")
                  end
                end
              end
              self.options[:singleton] = true if model.respond_to?(:instance)
              self.attributes = attr
            end
            self.options[:editor] = true if self.options[:view]
            self.options[:event] = true if self.options[:cache]
            self.options.freeze
          end
        end
      end

      public
      def create_model_file
        if options[:model]
          template 'Model.java', File.join(java_root, models_package.gsub(/\./, "/"), class_path, "#{class_name}.java")
        end
      end

      def create_cache_file
        if options[:cache] && !options[:singleton] && !options[:read_only]
          template 'Cache.java', File.join(java_root, caches_package.gsub(/\./, "/"), class_path, "#{class_name}Cache.java")
        end
      end

      def create_event_files
        if options[:event]
          template 'Event.java', File.join(java_root, events_package.gsub(/\./, "/"), class_path, "#{class_name}Event.java")
          template 'EventHandler.java', File.join(java_root, events_package.gsub(/\./, "/"), class_path, "#{class_name}EventHandler.java")
        end
      end

      def create_rest_service_file
        if options[:rest_service]
          template 'RestService.java', File.join(java_root, restservices_package.gsub(/\./, "/"), class_path, "#{controller_class_name}RestService.java")
        end
      end

      def create_editor_files
        if options[:editor]
          template 'Editor.java', File.join(java_root, editors_package.gsub(/\./, "/"), class_path, "#{class_name}Editor.java")
          template 'Editor.ui.xml', File.join(java_root, editors_package.gsub(/\./, "/"), class_path, "#{class_name}Editor.ui.xml")
        end
      end

      def create_view_files
        if options[:view]
          template('SimpleView.java', 
                   File.join(java_root, 
                             views_package.gsub(/\./, "/"), 
                             class_path, 
                             "#{class_name}View.java"))
          template('SimpleViewImpl.java', 
                   File.join(java_root, 
                             views_package.gsub(/\./, "/"), 
                             class_path, 
                             "#{class_name}ViewImpl.java"))
          template('SimpleView.ui.xml', 
                   File.join(java_root, 
                             views_package.gsub(/\./, "/"), 
                             class_path, 
                             "#{class_name}View.ui.xml"))
          unless options[:singleton]
            template('SimpleListView.java', 
                     File.join(java_root, 
                               views_package.gsub(/\./, "/"), 
                               class_path,
                               "#{class_name}ListView.java"))
            template('SimpleListViewImpl.java', 
                     File.join(java_root, 
                               views_package.gsub(/\./, "/"), 
                               class_path, 
                               "#{class_name}ListViewImpl.java"))
            template('SimpleListView.ui.xml', 
                     File.join(java_root, 
                               views_package.gsub(/\./, "/"), 
                               class_path, 
                               "#{class_name}ListView.ui.xml"))
          end
          template('AbstractPresenter.java', 
                   File.join(java_root, 
                             presenters_package.gsub(/\./, "/"), 
                             class_path, 
                             "AbstractPresenter.java"))
          template('Presenter.java', 
                   File.join(java_root, 
                             presenters_package.gsub(/\./, "/"), 
                             class_path, 
                             "#{class_name}Presenter.java"))
        end
      end

      def add_to_module
        file = File.join(java_root, managed_package.gsub(/\./, "/"), class_path, "#{application_name}Module.java")
        if File.exists?(file) && options[:restservice]
          content = File.read(file)
          if content =~ /#{class_name.pluralize}RestService.class/
            log 'keep', file
          else content =~ /super.configure\(\);/
            content.sub! /super.configure\(\);/, "super.configure();\n        bind(#{restservices_package}.#{class_name.pluralize}RestService.class).toProvider(#{class_name.pluralize}RestServiceProvider.class);"

            content.sub! /new GinFactoryModuleBuilder\(\)/, "new GinFactoryModuleBuilder()\n            .implement(Activity.class, Names.named(\"#{table_name}\"), #{activities_package}.#{class_name}Activity.class)"

            content.sub! /^\}/, <<-EOF

    @Singleton
    public static class #{class_name.pluralize}RestServiceProvider implements Provider<#{restservices_package}.#{class_name.pluralize}RestService> {
        private final #{restservices_package}.#{class_name.pluralize}RestService service = GWT.create(#{restservices_package}.#{class_name.pluralize}RestService.class);
        public #{restservices_package}.#{class_name.pluralize}RestService get() {
            return service;
        }
    }
}
EOF
            File.open(file, 'w') { |f| f.print content }
            log "added to", file
          end
        end
      end

      private

      def controller_class_name
        @controller_class_name ||= class_name.pluralize
      end

      def actions
        @actions ||= 
          begin
            keys = action_map.keys
            if options[:singleton]
              keys.delete('index')
              keys.delete('create')
              keys.delete('destroy')
            end
            if options[:read_only]
              keys.delete('update')
              keys.delete('create')
              keys.delete('destroy')
            end
            keys
          end
      end
    end
  end
end