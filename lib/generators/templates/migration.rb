class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :<%= table_name %> do |t|
<% attributes.select {|attr| ![:has_one, :has_many].include?(attr.type) }.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %><%= attribute.inject_options %>
<% end -%>
<% if options[:timestamps] %>
      t.timestamps
<% end -%>
<% if options[:modified_by] %>
      t.references :modified_by
<% end -%>
    end
<% attributes_with_index.each do |attribute| -%>
    add_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>
<% end -%>
  end
end
