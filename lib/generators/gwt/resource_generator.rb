require 'rails/generators/named_base'
module Gwt
  module Generators
    class ResourceGenerator < ::Rails::Generators::NamedBase

      class_option :singleton, :type => :boolean

      def add_resource_route
        return if options[:actions].present?
        route_config =  regular_class_path.collect{ |namespace| "namespace :#{namespace} do " }.join(" ")
        if options[:singleton]
          route_config << "resource :#{file_name.singularize}"
        else
          route_config << "resources :#{file_name.pluralize}"
        end
        route_config << " end" * regular_class_path.size
        route route_config
      end
    end
  end
end

