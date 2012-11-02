package <%= base_package %>;

<% if options[:menu] -%>
import <%= managed_package %>.<%= application_class_name %>Menu;
<% end -%>
import <%= models_package %>.User;
import <%= presenters_package %>.LoginPresenter;

<% if options[:place] -%>
import com.google.gwt.activity.shared.ActivityManager;
<% end -%>
<% if options[:menu] -%>
import com.google.gwt.core.client.GWT;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.LayoutPanel;
import com.google.gwt.user.client.ui.Panel;
import com.google.gwt.user.client.ui.RootLayoutPanel;
import com.google.gwt.user.client.ui.ScrollPanel;
import com.google.gwt.user.client.ui.SimplePanel;
import com.google.gwt.user.client.ui.Widget;
<% else -%>
import com.google.gwt.user.client.ui.SimplePanel;
import com.google.gwt.user.client.ui.RootPanel;
<% end -%>
<% if options[:gin] -%>
import com.google.inject.Inject;
<% end -%>

import <%= gwt_rails_package %>.SessionApplication;

public class <%= application_class_name %>Application<% if options[:gin] -%> extends Composite<%end -%> implements SessionApplication<User> {

<% if ! options[:menu] -%>
    private final SimplePanel display = new SimplePanel();
<% else -%>
    interface Binder extends UiBinder<Widget, <%= application_class_name %>Application> {}

    private static Binder BINDER = GWT.create(Binder.class);

    @UiField(provided=true) final SimplePanel display = new ScrollPanel();
    @UiField(provided=true) Panel header;
    @UiField(provided=true) Panel navigation<% unless options[:menu] %> = new SimplePanel()<% end -%>;
    @UiField(provided=true) Panel footer<% unless options[:remote_users] %> = new SimplePanel()<% end -%>;
<% end -%>

<% if options[:gin] -%>
    @Inject
<% end -%>
    <%= application_class_name %>Application(<% if options[:place] -%>final ActivityManager activityManager<% end -%><% if options[:menu] -%>, 
            final <%= application_class_name %>Menu menu<% end -%>, 
            final BreadCrumbsPanel breadCrumbs<% if options[:remote_users] -%>,
            final ApplicationLinksPanel links<% end -%>,
            final LoginPresenter presenter){
        presenter.init(this);
<% if options[:place] -%>
        activityManager.setDisplay(display);
<% end -%>
<% if options[:menu] -%>
        this.navigation = menu;
<% end -%>
<% if options[:remote_users] -%>
        this.footer = links;
<% end -%>
        this.header = breadCrumbs;
        initWidget(BINDER.createAndBindUi(this));
    }

    @Override
    public void run() {
<% if options[:menu] -%>
        LayoutPanel root = RootLayoutPanel.get();
        root.add(this.asWidget());
<% else -%>
        RootPanel.get().add(panel);
	//TODO do something here
<% end -%>
    }

    @Override
    public void startSession(User user) {
        ((BreadCrumbsPanel) this.header).initUser(user);
<% if options[:remote_users] -%>
        ((ApplicationLinksPanel) this.footer).initUser(user);
<% end -%>
<% if options[:menu] -%>
        this.navigation.setVisible(true);
<% end -%>
    }

    @Override
    public void stopSession() {
        ((BreadCrumbsPanel) this.header).initUser(null);
<% if options[:remote_users] -%>
        ((ApplicationLinksPanel) this.footer).initUser(null);
<% end -%>
<% if options[:menu] -%>
        this.navigation.setVisible(false);
<% end -%>
    }
}
