package <%= base_package %>;

<% if options[:place] -%>
<% indent = '//' -%>
import com.google.gwt.place.shared.PlaceController;
<% else -%>
<% indent = '' -%>
<% end -%>
<%= indent -%>import com.google.gwt.user.client.Window;

public class GwtRailsConfirmation<% if options[:place] -%> extends PlaceController.DefaultDelegate<% end -%> {      
<%= indent -%>    public boolean confirm(String message) {
<%= indent -%>        return Window.confirm(message);
<%= indent -%>    }
}