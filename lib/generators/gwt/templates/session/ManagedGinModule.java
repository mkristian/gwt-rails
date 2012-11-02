package <%= managed_package %>;

import <%= gwt_rails_package %>.Base<%= options[:place] ? '' : 'Gin' %>Module;

<% if options[:place] -%>
import <%= activities_package %>.LoginActivity;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.inject.client.assistedinject.GinFactoryModuleBuilder;
import com.google.inject.name.Names;
<% end -%>
import com.google.gwt.core.client.GWT;
import com.google.inject.Provider;
import com.google.inject.Singleton;

public class ManagedGinModule extends Base<%= options[:place] ? '' : 'Gin' %>Module {

   @Override
    protected void configure() {
        super.configure();
<% if options[:place] -%>
        install(new GinFactoryModuleBuilder()
            .implement(Activity.class, Names.named("login"), LoginActivity.class)
            .build(ActivityFactory.class));
<% end -%>
    }
}
