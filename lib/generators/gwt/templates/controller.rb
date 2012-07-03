class <%= controller_class_name %>Controller < ApplicationController

  private

  def cleanup
    super params[:<%= singular_table_name %>]
  end

  public

  # GET <%= route_url %>
  def index
    @<%= plural_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.all(class_name) %><% if options[:serializer] -%>).use(:collection)<% end -%>

    respond_with @<%= plural_table_name %>
  end

  # GET <%= route_url %>/1
  def show
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.find(class_name, "params[:id]") %><% if options[:serializer] -%>)<% end -%>

    respond_with @<%= singular_table_name %>
  end

  # POST <%= route_url %>
  def create
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.build(class_name, "params[:#{singular_table_name}]") %><% if options[:serializer] -%>)<% end -%>
<% if options[:modified_by] -%>
    @<%= singular_table_name %>.modified_by = current_user
<% end -%>

    @<%= orm_instance.save %>

    respond_with @<%= singular_table_name %>
  end

  # PUT <%= route_url %>/1
  def update
<% if options[:optimistic] && options[:timestamps] -%>
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.find(class_name, "params[:updated_at], params[:id]").sub(/\.(get|find)/, '.optimistic_\1') %><% if options[:serializer] -%>)<% end -%>
<% else -%>
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.find(class_name, "params[:id]") %><% if options[:serializer] -%>)<% end -%>
<% end -%>

    @<%= singular_table_name %>.attributes = params[:<%= singular_table_name %>]
<% if options[:modified_by] -%>
    @<%= singular_table_name %>.modified_by = current_user if @<%= singular_table_name %>.dirty?
<% end -%>

    @<%= orm_instance.save %>

    respond_with @<%= singular_table_name %>
  end

  # DELETE <%= route_url %>/1
  def destroy
<% if options[:optimistic] && options[:timestamps] -%>
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:updated_at], params[:id]").sub(/\.(get|find)/, '.optimistic_\1') %>
<% else -%>
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
<% end -%>

    @<%= orm_instance.destroy %>

    respond_with @<%= singular_table_name %>
  end
end
