package <%= base_package %>;

<% if options[:menu] -%>
import <%= managed_package %>.<%= application_class_name %>Menu;

<% end -%>
<% if options[:place] -%>
import com.google.gwt.activity.shared.ActivityManager;
<% end -%>
<% if options[:menu] -%>
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Style.Unit;
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

import <%= gwt_rails_package %>.Application;

public class <%= application_class_name %>Application<% if options[:gin] -%> extends Composite<%end -%> implements Application {

<% if ! options[:menu] -%>
    private final SimplePanel display = new SimplePanel();
<% else -%>
    interface Binder extends UiBinder<Widget, <%= application_class_name %>Application> {}

    private static Binder BINDER = GWT.create(Binder.class);

    @UiField(provided=true) final SimplePanel display = new ScrollPanel();
    @UiField(provided=true) Panel header;
    @UiField(provided=true) Panel navigation;
    @UiField(provided=true) Panel footer;
<% end -%>

<% if options[:gin] -%>
    @Inject
<% end -%>
    <%= application_class_name %>Application(<% if options[:place] -%>ActivityManager activityManager<% end -%><% if options[:menu] -%>, <%= application_class_name %>Menu menu<% end -%>){
<% if options[:place] -%>
        activityManager.setDisplay(display);
<% end -%>
<% if options[:menu] -%>
        this.navigation = menu;
        initWidget(BINDER.createAndBindUi(this));
<% end -%>
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
}
