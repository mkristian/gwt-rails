package <%= managed_package %>;

import <%= base_package %>.<%= application_class_name %>Application;
import <%= base_package %>.<%= application_class_name %>Confirmation;
<% if options[:place] -%>
import <%= base_package %>.<% if options[:session] -%>Session<% end -%>ActivityPlaceActivityMapper;
<% end -%>
<% if options[:session] -%>
import <%= activities_package %>.LoginActivity;
<% end -%>
import <%= gwt_rails_package %>.Application;
import <%= gwt_rails_package %>.Base<%= options[:place] ? '' : 'Gin' %>Module;

<% if options[:place] -%>
import com.google.gwt.activity.shared.Activity;
import com.google.gwt.activity.shared.ActivityMapper;
<% end -%>
import com.google.gwt.core.client.GWT;
<% if options[:place] -%>
import com.google.gwt.inject.client.assistedinject.GinFactoryModuleBuilder;
import com.google.gwt.place.shared.PlaceController.Delegate;
import com.google.gwt.place.shared.PlaceHistoryMapper;
<% end -%>
import com.google.inject.Provider;
import com.google.inject.Singleton;
import com.google.inject.name.Names;

<% if options[:session] -%>
import <%= views_package %>.LoginViewImpl;

import <%= gwt_rails_session_package %>.LoginView;
<% end -%>
public class <%= application_class_name %>Module extends Base<%= options[:place] ? '' : 'Gin' %>Module {

    @Override
    protected void configure() {
        super.configure();
        bind(Application.class).to(<%= application_class_name %>Application.class);
<% if options[:place] -%>
        bind(PlaceHistoryMapper.class).to(<%= application_class_name %>PlaceHistoryMapper.class).in(Singleton.class);
        bind(ActivityMapper.class).to(<% if options[:session] -%>Session<% end -%>ActivityPlaceActivityMapper.class).in(Singleton.class);
        bind(Delegate.class).to(GwtRailsConfirmation.class).in(Singleton.class);
<% end -%>
        bind(GwtRailsConfirmation.class).to(GwtRailsConfirmation.class).in(Singleton.class);
<% if options[:session] -%>
        bind(LoginView.class).to(LoginViewImpl.class);
<% end -%>
<% if options[:place] -%>
        install(new GinFactoryModuleBuilder()
<% if options[:session] -%>
		.implement(Activity.class, Names.named("login"), LoginActivity.class)
<% end -%>
            .build(ActivityFactory.class));
<% end -%>
    }
}