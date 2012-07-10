require 'ixtlan/babel/serializer'

class <%= class_name %>Serializer < Ixtlan::Babel::Serializer

  model <%= class_name %>

  add_context(:single,
              :root => '<%= singular_table_name %>'<% 
except = []
except << :id if options[:singleton]
except << :modified_by_id if options[:modified_by]
-%>
<% unless except.empty? -%>,
              :except => <%= except.inspect %>
<% end -%>
<% if options[:modified_by] || attributes.select {|attr| attr.reference? }.size > 0 -%>,
              :include => {
<% if options[:modified_by] -%>
                :modified_by => {
                  :only => [:id, :login, :name]
                }<% end -%><% attributes.select {|attr| attr.reference? }.each do |attribute| -%>,
                :<%= attribute.name %> => {
                  :except => [:created_at, :updated_at, :modified_by_id]
                }<% end %>
              }
<% end -%>
             )
<% unless options[:singleton] -%>

<% 
except = []
if options[:timestamps]
  except = [:created_at]
  except << :updated_at unless options[:optimistic]
end
except << :modified_by_id if options[:modified_by]
-%>
  add_context(:collection,
              :root => '<%= singular_table_name %>',
              :except => <%= except.inspect %>
              )
<% end -%>

  default_context_key :single
end
