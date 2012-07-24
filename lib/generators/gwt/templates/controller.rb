class <%= controller_class_name %>Controller < ApplicationController
<% unless options[:read_only] -%>

  private

  def cleanup
    super(params[:<%= singular_table_name %>])
  end
<% end -%>

  public
<% unless options[:singleton] -%>

  # GET <%= route_url %>
  def index
    @<%= plural_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.all(class_name) %><% if options[:serializer] -%>).use(:collection)<% end -%>

    respond_with @<%= plural_table_name %>
  end
<% end -%>

  # GET <%= route_url %><% unless options[:singleton] -%>/1<% end %>
  def show
<% if options[:singleton] -%>
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= class_name %>.instance<% if options[:serializer] -%>)<% end -%>
<% else -%>
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.find(class_name, "params[:id]") %><% if options[:serializer] -%>)<% end -%>
<% end -%>

    respond_with @<%= singular_table_name %>
  end
<% if !options[:singleton] && !options[:read_only] -%>

  # POST <%= route_url %>
  def create
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.build(class_name, "params[:#{singular_table_name}]") %><% if options[:serializer] -%>)<% end -%>
<% if options[:modified_by] -%>
    @<%= singular_table_name %>.modified_by = current_user
<% end -%>

    @<%= orm_instance.save %>

    respond_with @<%= singular_table_name %>
  end
<% end -%>
<% unless options[:read_only] -%>

  # PUT <%= route_url %>/1
  def update
<% if options[:optimistic] && options[:timestamps] -%>
<%   if options[:singleton] -%>
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.find(class_name, "updated_at, #{class_name}.instance.id").sub(/\.(get|get\!|find)/, '.optimistic_\1') %><% if options[:serializer] -%>)<% end -%>
<%   else -%>
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.find(class_name, "updated_at, params[:id]").sub(/\.(get|find)/, '.optimistic_\1') %><% if options[:serializer] -%>)<% end -%>
<%   end -%>
<% else -%>
<%   if options[:singleton] -%>
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= class_name %>.instance<% if options[:serializer] -%>)<% end -%>
<%   else -%>
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.find(class_name, "params[:id]") %><% if options[:serializer] -%>)<% end -%>
<%   end -%>
<% end -%>

    @<%= singular_table_name %>.attributes = params[:<%= singular_table_name %>]
<% if options[:modified_by] -%>
    @<%= singular_table_name %>.modified_by = current_user if @<%= singular_table_name %>.dirty?
<% end -%>

    @<%= orm_instance.save %>

    respond_with @<%= singular_table_name %>
  end
<% end -%>
<% if !options[:singleton] && !options[:read_only] -%>

  # DELETE <%= route_url %>/1
  def destroy
<% if options[:optimistic] && options[:timestamps] -%>
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "updated_at, params[:id]").sub(/\.(get|find)/, '.optimistic_\1') %>
<% else -%>
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
<% end -%>

    @<%= orm_instance.destroy %>

    respond_with @<%= singular_table_name %>
  end
<% end -%>
end
