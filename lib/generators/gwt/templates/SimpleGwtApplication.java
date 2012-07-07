package <%= base_package %>;

<% if options[:menu] -%>
import <%= managed_package %>.<%= application_class_name %>Menu;

<% end -%>
<% if options[:place] -%>
import com.google.gwt.activity.shared.ActivityManager;
<% end -%>
import com.google.gwt.user.client.ui.SimplePanel;
import com.google.gwt.user.client.ui.RootPanel;
<% if options[:gin] -%>
import com.google.inject.Inject;
<% end -%>

import <%= gwt_rails_package %>.Application;

public class <%= application_class_name %>Application implements Application {

    private final SimplePanel panel = new SimplePanel();
<% if options[:menu] -%>
    private final <%= application_class_name %>Menu menu;
<% end -%>

<% if options[:gin] -%>
    @Inject
<% end -%>
    <%= application_class_name %>Application(<% if options[:place] -%>ActivityManager activityManager<% end -%><% if options[:menu] -%>, <%= application_class_name %>Menu menu<% end -%>){
<% if options[:place] -%>
        activityManager.setDisplay(panel);
<% end -%>
<% if options[:menu] -%>
        this.menu = menu;
<% end -%>
    }

    public void run() {
<% if options[:menu] -%>
        RootPanel.get().add(menu);
<% end -%>
        RootPanel.get().add(panel);
	//TODO do something here
    }
}
