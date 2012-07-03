package <%= base_package %>;

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

<% if options[:gin] -%>
    @Inject
<% end -%>
    <%= application_class_name %>Application(<% if options[:place] -%>ActivityManager activityManager<% end -%>){
<% if options[:place] -%>
        activityManager.setDisplay(panel);
<% end -%>
    }

    public void run() {
        RootPanel.get().add(panel);
	//TODO do something here
    }
}