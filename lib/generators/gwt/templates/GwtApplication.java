package <%= base_package %>;

<% if options[:menu] -%>
import <%= managed_package %>.<%= application_class_name %>MenuPanel;
<% end -%>
import <%= managed_package %>.<%= application_class_name %>Module;

<% if options[:place] -%>
import com.google.gwt.activity.shared.ActivityManager;
<% end -%>
import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.inject.client.GinModules;
import com.google.gwt.inject.client.Ginjector;
<% if options[:place] -%>
import com.google.gwt.place.shared.PlaceHistoryHandler;
<% end -%>
import com.google.gwt.user.client.ui.Panel;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.inject.Inject;

import <%= gwt_rails_package %>.Application;
import <%= gwt_rails_package %>.Notice;
import <%= gwt_rails_package %>.dispatchers.DefaultDispatcherSingleton;

public class <%= application_class_name %>Application extends Application {
    private final Notice notice;
<% if options[:session] -%>
    private final BreadCrumbsPanel breadCrumbs;
<% end -%>
<% if options[:menu] -%>
    private final <%= application_class_name %>MenuPanel menu;
<% end -%>
<% if options[:remote_users] -%>
    private final ApplicationLinksPanel links;
<% end -%>
    private RootPanel root;

    @Inject
    <%= application_class_name %>Application(final Notice notice<% if options[:session] || options[:menu] || options[:place] || options[:remote_user] -%>,
<% if options[:session] -%>
                                           final BreadCrumbsPanel breadCrumbs,
<% end -%>
<% if options[:menu] -%>
                                           final <%= application_class_name %>MenuPanel menu,
<% end -%>
<% if options[:place] -%>
                                           final ActivityManager activityManager
<% end -%>
<% if options[:remote_users] -%>,
                                           final ApplicationLinksPanel links<% end -%><% end -%>){
<% if options[:place] -%>
        super(activityManager);
<% end -%>
        this.notice = notice;
<% if options[:session] -%>
        this.breadCrumbs = breadCrumbs;
<% end -%>
<% if options[:menu] -%>
        this.menu = menu;
<% end -%>
<% if options[:remote_users] -%>
        this.links = links;
<% end -%>
    }

    protected void initApplicationPanel(Panel panel) {
        if (this.root == null) {
            this.root = RootPanel.get();
            this.root.add(notice);
<% if options[:session] -%>
            this.root.add(breadCrumbs);
<% end -%>
<% if options[:menu] -%>
            this.root.add(menu);
<% end -%>
            this.root.add(panel);
<% if options[:remote_users] -%>
            this.root.add(links);
<% end -%>
        }
    }
}