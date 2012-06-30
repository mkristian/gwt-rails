require 'rails/generators/resource_helpers'
require 'rails/generators/named_base'
module Gwt
  module Generators
    class ScaffoldGenerator < ::Rails::Generators::NamedBase
      include ::Rails::Generators::ResourceHelpers

      source_root File.expand_path('templates', File.dirname(__FILE__))

      #argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      check_class_collision :suffix => "Controller"

      class_option :orm, :banner => "NAME", :type => :string, :required => true,
                         :desc => "ORM to generate the controller for"

      class_option :singleton, :type => :boolean, :default => false
      class_option :optimistic, :type => :boolean, :default => false
      class_option :serializer, :type => :boolean, :default => false
      class_option :modified_by, :type => :string
      class_option :timestamps, :type => :boolean, :default => true

      def create_controller_files
        if options[:singleton]
          template 'singleton_controller.rb', File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
        else
          template 'controller.rb', File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
        end
      end
      
      hook_for :test_framework, :as => :scaffold, :in => :rails
      hook_for :template_engine, :as => :scaffold, :in => :gwt

      # Invoke the helper using the controller name (pluralized)
      hook_for :helper, :as => :scaffold, :in => :rails do |invoked|
        invoke invoked, [ controller_name ]
      end
    end
  end
end
