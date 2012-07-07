package <%= base_package %>;

<% if options[:place] -%>
<% indent = '//' -%>
import com.google.gwt.place.shared.PlaceController;
<% else -%>
<% indent = '' -%>
<% end -%>
<%= indent -%>import com.google.gwt.user.client.Window;
<% if options[:gin] -%>

import javax.inject.Singleton;
<% end -%>

<% if options[:gin] -%>
@Singleton
<% end -%>
public class <%= application_class_name %>Confirmation<% if options[:place] -%> extends PlaceController.DefaultDelegate<% end -%> {      
<%= indent -%>    public boolean confirm(String message) {
<%= indent -%>        return Window.confirm(message);
<%= indent -%>    }
}
