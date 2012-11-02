package <%= managed_package %>;

import <%= base_package %>.<%= application_class_name %>Application;
import <%= base_package %>.<%= application_class_name %>Confirmation;
<% if options[:place] -%>
import <%= base_package %>.ActivityPlaceActivityMapper;
<% end -%>
import <%= managed_package %>.ManagedGinModule;

import <%= gwt_rails_package %>.Application;

<% if options[:place] -%>
import com.google.gwt.activity.shared.Activity;
import com.google.gwt.activity.shared.ActivityMapper;
<% end -%>
import com.google.gwt.core.client.GWT;
<% if options[:place] -%>
import com.google.gwt.place.shared.PlaceController.Delegate;
import com.google.gwt.place.shared.PlaceHistoryMapper;
<% end -%>

public class <%= application_class_name %>GinModule extends ManagedGinModule {

    @Override
    protected void configure() {
        super.configure();
        bind(Application.class).to(<%= application_class_name %>Application.class);
<% if options[:place] -%>
        bind(PlaceHistoryMapper.class).to(<%= application_class_name %>PlaceHistoryMapper.class).in(Singleton.class);
        bind(ActivityMapper.class).to(ActivityPlaceActivityMapper.class).in(Singleton.class);
        bind(Delegate.class).to(<%= application_class_name %>Confirmation.class);
<% end -%>
        bind(<%= application_class_name %>Confirmation.class);
    }
}
