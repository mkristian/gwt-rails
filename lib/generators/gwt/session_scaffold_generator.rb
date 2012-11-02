require 'rails/generators/resource_helpers'
require 'rails/generators/named_base'
require 'generators/setup_options'
module Gwt
  module Generators
    class SessionScaffoldGenerator < ::Rails::Generators::NamedBase
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

      hook_for :guard, :in => :guard, :default => 'scaffold'

    end
  end
end
