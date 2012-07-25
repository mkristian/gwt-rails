require 'rails/generators/resource_helpers'
require 'rails/generators/named_base'
require 'generators/setup_options'
module Gwt
  module Generators
    class ScaffoldGenerator < ::Rails::Generators::NamedBase
      include ::Rails::Generators::ResourceHelpers
      include SetupOptions

      source_root File.expand_path('templates', File.dirname(__FILE__))

      argument(:attributes,       :type => :array, :default => [], 
               :banner => "field:type field:type field:belongs_to", :desc => 'if no fields are given and there is a model in RAILS_ROOT/app/models then the attrbutes/properties of the model is the source of the fields')

      check_class_collision :suffix => "Controller"

      class_option :orm, :banner => "NAME", :type => :string, :required => true,
                         :desc => "ORM to generate the controller for"

      class_option :singleton,   :type => :boolean, :default => false
      class_option :read_only,   :type => :boolean, :default => false
      class_option :optimistic,  :type => :boolean, :default => false
      class_option :serializer,  :type => :boolean, :default => false
      class_option :modified_by, :type => :string
      class_option :timestamps,  :type => :boolean, :default => true

      def patch_datamapper_active_model
        if @orm_class.nil? && defined? DataMapper
          require 'generators/data_mapper'
          DataMapper::Generators::ActiveModel.class_eval do
            def self.find(klass, params=nil)
              "#{klass}.get!(#{params})"
            end
          end
        end
      end

      def create_controller_files
        setup_options
        template 'controller.rb', File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
      end

      def create_serializer_files
        if options[:serializer]
          parse_attributes!
          template 'serializer.rb', File.join('app', 'serializers', "#{singular_table_name}_serializer.rb")
        end
      end

      hook_for :test_framework, :as => :scaffold, :in => :rails
      hook_for :template_engine, :as => :scaffold, :in => :gwt

      # Invoke the helper using the controller name (pluralized)
      hook_for :helper, :as => :scaffold, :in => :rails do |invoked|
        invoke invoked, [ controller_name ]
      end

      no_tasks do

        if defined? ActiveRecord

          def parse_attributes! #:nodoc:
            #super
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
            else
              super if attributes.first.is_a? String
            end
          end
        end
      end

    end
  end
end
