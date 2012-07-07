require 'rails/generators/resource_helpers'
require 'generators/base'
module Gwt
  module Generators
    class UiGenerator < Base

      source_root File.expand_path('templates', File.dirname(__FILE__))

      argument(:attributes,       :type => :array, :default => [], 
               :banner => "field:type field:type field:belongs_to", :desc => 'if no fields are given and there is a model in RAILS_ROOT/app/models then the attrbutes/properties of the model is the source of the fields')

      class_option :timestamps,   :type => :boolean#, :default => true
      class_option :optimistic,   :type => :boolean#, :default => false
#      class_option :modified_by,  :type => :string,  :desc => 'class name for the modified_by field. GWT class must implement interface IsUser'
      class_option :read_only,    :type => :boolean#, :default => false
      class_option :singleton,    :type => :boolean#, :default => false
      class_option(:parent,       :type => :string,  
                   :desc => "The parent class for the generated model")
      class_option :model,        :type => :boolean, :default => true
      class_option :rest_service, :type => :boolean, :default => true
      class_option(:cache,        :type => :boolean,# :default => false,
                   :desc => 'Uses a cache for loading models. Implies event = true')
      class_option(:store,        :type => :boolean,# :default => false,
                   :desc => 'Uses a localstore for loading models. Implies cache = true')
      class_option :event,        :type => :boolean#, :default => false
      class_option :editor,       :type => :boolean#, :default => false
      class_option(:view,         :type => :boolean,# :default => false,
                   :desc => 'Simple view classes for manipulating models. Implies editor = true')
      class_option :gin,          :type => :boolean#, :default => false
      class_option(:place,        :type => :boolean,# :default => false,
                   :desc => 'adds GWT place, i.e bookmarkable screens. Implies view = true')

      no_tasks do

        if defined? ActiveRecord

          def parse_attributes! #:nodoc:
            super
            if self.attributes.empty?
              self.options = self.options.dup
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
              self.options.freeze
            end
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
            if self.attributes.empty?
              self.options = self.options.dup
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
              self.options.freeze
            end
          end
        end
      end

      public

      def setup_options
         super
      end

      def create_model_file
        if options[:model]
          template 'Model.java', File.join(java_root, models_package.gsub(/\./, "/"), class_path, "#{class_name}.java")
        end
      end

      def create_cache_file
        if options[:cache] && !options[:singleton]
          template 'Cache.java', File.join(java_root, caches_package.gsub(/\./, "/"), class_path, "#{class_name}Cache#{ 'Store' if options[:store] }.java")
        end
      end

      def create_event_files
        if options[:event] && !options[:singleton]
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
      def create_place_files
        if options[:place]
          template('Place.java', 
                   File.join(java_root, 
                             places_package.gsub(/\./, "/"), 
                             class_path, 
                             "#{class_name}Place.java"))
          template('PlaceTokenizer.java', 
                   File.join(java_root, 
                             places_package.gsub(/\./, "/"), 
                             class_path, 
                             "#{class_name}PlaceTokenizer.java"))
        end
      end

      def create_activity_file
        if options[:place]
          template('Activity.java', 
                   File.join(java_root, 
                             activities_package.gsub(/\./, "/"), 
                             class_path, 
                             "#{class_name}Activity.java"))
        end
      end

      def add_to_activity_factory
        if options[:place]
          factory_file = File.join(java_root, managed_package.gsub(/\./, "/"), class_path, "ActivityFactory.java")
          if File.exists?(factory_file)
            factory = File.read(factory_file)
            if factory =~ /@Named\(.#{table_name}.\)/
              log 'keep', factory_file
            else
              factory.sub! /interface\s+ActivityFactory\s+\{/, "interface ActivityFactory {\n    @Named(\"#{table_name}\") Activity create(#{places_package}.#{class_name}Place place);"
              File.open(factory_file, 'w') { |f| f.print factory }
              log "added to", factory_file
            end
          end
        end
      end

      def add_to_place_history_mapper
        if options[:place]
          file = File.join(java_root, managed_package.gsub(/\./, "/"), class_path, "#{application_class_name}PlaceHistoryMapper.java")
          if File.exists?(file)
            content = File.read(file)
            if content =~ /#{class_name}PlaceTokenizer/
              log 'keep', file
            else
              content.sub! /public\s+#{application_class_name}PlaceHistoryMapper.(.*).\s*\{/ do |m|
                "public #{application_class_name}PlaceHistoryMapper(#{$1}){\n        register(\"#{table_name}\", new #{places_package}.#{class_name}PlaceTokenizer());"
              end
              File.open(file, 'w') { |f| f.print content }
              log "added to", file
            end
          end
        end
      end
 
      def add_to_menu_panel
        file = File.join(java_root, managed_package.gsub(/\./, "/"), class_path, "#{application_class_name}Menu.java")
        if File.exists?(file)
          content = File.read(file)
          if content =~ /#{class_name}Place\(/
            log 'keep', file
          else
            # TODO non session case !!!
            t_name = options[:singleton] ? singular_table_name : table_name
            content.sub! /super\(\s*sessionManager\s*,\s*placeController\s*\)\s*;/, "super(sessionManager, placeController);\n        addButton(\"#{t_name.underscore.humanize}\", new #{places_package}.#{class_name}Place(#{options[:singleton] ? 'SHOW' : 'INDEX'}));"
            content.sub! /super\(\s*placeController\s*\)\s*;/, "super(placeController);\n        addButton(\"#{t_name.underscore.humanize}\", new #{places_package}.#{class_name}Place(#{options[:singleton] ? 'SHOW' : 'INDEX'}));"
            File.open(file, 'w') { |f| f.print content }
            log "added to", file
          end
        end
      end

      def add_to_module
        file = File.join(java_root, managed_package.gsub(/\./, "/"), class_path, "#{application_class_name}Module.java")
        if File.exists?(file) && (options[:rest_service] || options[:place])
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
