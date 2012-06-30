class <%= controller_class_name %>Controller < ApplicationController

  before_filter :cleanup_params

  private

  def cleanup_params
    # compensate the shortcoming of the incoming json/xml
    model = params[:<%= singular_table_name %>] || []
    model.delete :id
<% if options[:timestamps] -%>
    model.delete :created_at
    <% if options[:optimistic] -%>params[:updated_at] ||= <% end -%>model.delete :updated_at
<% end -%>
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
<% indent = '  ' -%>
    if @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.find(class_name, "params[:updated_at], params[:id]").sub(/\.(get|find)/, '.optimistic_\1') %><% if options[:serializer] -%>)<% end -%>
<% else -%>
    @<%= singular_table_name %> = <% if options[:serializer] -%>serializer(<% end -%><%= orm_class.find(class_name, "params[:id]") %><% if options[:serializer] -%>)<% end -%>
<% end -%>

    <%= indent -%>@<%= singular_table_name %>.attributes = params[:<%= singular_table_name %>]
<% if options[:modified_by] -%>
    <%= indent -%>@<%= singular_table_name %>.modified_by = current_user if @<%= singular_table_name %>.dirty?
<% end -%>

    <%= indent -%>@<%= orm_instance.save %>

    <%= indent -%>respond_with @<%= singular_table_name %>
<% if options[:optimistic] && options[:timestamps] -%>
    else
      head :conflict
    end
<% end -%>
  end

  # DELETE <%= route_url %>/1
  def destroy
<% if options[:optimistic] && options[:timestamps] -%>
<% indent = '  ' -%>
    if @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:updated_at], params[:id]").sub(/\.(get|find)/, '.optimistic_\1') %>
<% else -%>
    <%= indent -%>@<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
<% end -%>

    <%= indent -%>@<%= orm_instance.destroy %>

    <%= indent -%>respond_with @<%= singular_table_name %>
<% if options[:optimistic] && options[:timestamps] -%>
    else
      head :conflict
    end
<% end -%>
  end
end
