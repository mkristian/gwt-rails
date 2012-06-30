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

import org.fusesource.restygwt.client.Defaults;

/**
 * Entry point classes define <code>onModuleLoad()</code>.
 */
public class <%= application_class_name %>EntryPoint implements EntryPoint {

    @GinModules(<%= application_class_name %>Module.class)
    static public interface <%= application_class_name %>Ginjector extends Ginjector {
<% if options[:place] -%>
        PlaceHistoryHandler getPlaceHistoryHandler();
<% end -%>
        Application getApplication();
    }

    /**
     * This is the entry point method.
     */
    public void onModuleLoad() {
        Defaults.setServiceRoot(GWT.getModuleBaseURL().replaceFirst("[a-zA-Z0-9_]+/$", ""));
        Defaults.setDispatcher(DefaultDispatcherSingleton.INSTANCE);
        GWT.log("base url for restservices: " + Defaults.getServiceRoot());

        final <%= application_class_name %>Ginjector injector = GWT.create(<%= application_class_name %>Ginjector.class);

        // setup display
        injector.getApplication().run();
<% if options[:place] -%>
    
        // Goes to the place represented on URL else default place
        injector.getPlaceHistoryHandler().handleCurrentHistory();
<% end -%>
    }
}
