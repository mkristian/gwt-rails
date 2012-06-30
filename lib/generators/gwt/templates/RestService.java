package <%= restservices_package %>;

<% if options[:singleton] || !options[:cache] -%>
import <%= gwt_rails_package %>.dispatchers.RestfulDispatcherSingleton;
<% else -%>
import <%= gwt_rails_package %>.dispatchers.DefaultDispatcherSingleton;
<% end -%>
<% if action_map.values.member? :get_all -%>

import java.util.List;
<% end -%>

import javax.ws.rs.*;

<% unless options[:singleton] -%>
import org.fusesource.restygwt.client.Attribute;
<% end -%>
import org.fusesource.restygwt.client.MethodCallback;
import org.fusesource.restygwt.client.Options;
import org.fusesource.restygwt.client.RestService;

<% if name -%>
import <%= models_package %>.<%= class_name %>;
<% end -%>

<% if options[:singleton] || !options[:cache] -%>
<%   if options[:singleton] -%>
@Path("/<%= singular_table_name %>")
<%   end -%>
@Options(dispatcher = RestfulDispatcherSingleton.class)
<% else -%>
@Options(dispatcher = DefaultDispatcherSingleton.class)
<% end -%>
public interface <%= controller_class_name %>RestService extends RestService {

<% actions.each do |action| 
     case action_map[action]
     when :get_all -%>
  @GET @Path("/<%= table_name %>")
  void <%= action %>(MethodCallback<List<<%= class_name %>>> callback);

<%   when :get_single -%>
  @GET<% unless options[:singleton] -%> @Path("/<%= table_name %>/{id}")<% end %>
  void <%= action %>(<% unless options[:singleton] -%>@PathParam("id") int id, <% end -%>MethodCallback<<%= class_name %>> callback);

<%   when :post -%>
  @POST @Path("/<%= table_name %>")
  void <%= action %>(<%= class_name %> value, MethodCallback<<%= class_name %>> callback);

<%   when :put -%>
  @PUT<% unless options[:singleton] -%> @Path("/<%= table_name %>/{id}")<% end %>
  void <%= action %>(<% unless options[:singleton] -%>@PathParam("id") @Attribute("id") <% end -%><%= class_name %> value, MethodCallback<<%= class_name %>> callback);

<%   when :delete -%>
  @DELETE @Path("/<%= table_name %>/{id}")
  void <%= action %>(@PathParam("id") @Attribute("id") <%= class_name %> value, MethodCallback<Void> callback);

<%   else -%>
  @GET @Path("/<%= table_name %>/<%= action %>")
  void <%= action %>(MethodCallback<Void> callback);

<% end
end -%>
}
